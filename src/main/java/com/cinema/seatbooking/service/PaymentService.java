package com.cinema.seatbooking.service;

import com.cinema.seatbooking.common.BookingStatus;
import com.cinema.seatbooking.common.SeatStatus;
import com.cinema.seatbooking.config.PaymentConfig;
import com.cinema.seatbooking.entity.Booking;
import com.cinema.seatbooking.entity.ShowtimeSeat;
import com.cinema.seatbooking.exception.BadRequestException;
import com.cinema.seatbooking.exception.NotFoundException;
import com.cinema.seatbooking.repository.BookingRepository;
import com.cinema.seatbooking.repository.ShowtimeSeatRepository;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final BookingRepository bookingRepository;
    private final ShowtimeSeatRepository showtimeSeatRepository;
    private final PaymentConfig paymentConfig;

    // =================================================================================
    // 1. TẠO URL THANH TOÁN (CREATE PAYMENT URL)
    // =================================================================================
    public String createVnPayPayment(Long bookingId, HttpServletRequest request) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new RuntimeException("Booking is not in a valid state for payment");
        }
        long amount = (long) (booking.getTotalPrice() * 100);
        String vnp_TxnRef = String.valueOf(booking.getId());

        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", "2.1.0");
        vnp_Params.put("vnp_Command", "pay");
        vnp_Params.put("vnp_TmnCode", paymentConfig.getVnp_TmnCode());
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_BankCode", "NCB");
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", "Thanh toan don hang:" + vnp_TxnRef);
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", paymentConfig.getVnp_ReturnUrl());
        vnp_Params.put("vnp_IpAddr", PaymentConfig.getIpAddress(request)); // Giả sử method này static trong Config

        // Thời gian tạo
        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnp_CreateDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

        // Thời gian hết hạn (15 phút)
        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

        // Build Query URL & Hash (Sắp xếp theo Alphabet)
        String queryUrl = buildQueryString(vnp_Params);
        String vnp_SecureHash = paymentConfig.hmacSHA512(paymentConfig.getVnp_HashSecret(), queryUrl);

        return paymentConfig.getVnp_PayUrl() + "?" + queryUrl + "&vnp_SecureHash=" + vnp_SecureHash;
    }

    // =================================================================================
    // 2. XỬ LÝ CALLBACK & AUTO REFUND (PROCESS CALLBACK)
    // =================================================================================
    @Transactional
    public Map<String, Object> processVnPayCallback(Map<String, String> queryParams) {
        Map<String, Object> result = new HashMap<>();

        try {
            String vnp_ResponseCode = queryParams.get("vnp_ResponseCode");
            String bookingIdStr = queryParams.get("vnp_TxnRef");
            String vnp_SecureHash = queryParams.get("vnp_SecureHash");
            String vnp_PayDate = queryParams.get("vnp_PayDate"); // Quan trọng cho refund sau này

            // 1. Verify Checksum
            if (!verifyVnPaySignature(queryParams, vnp_SecureHash)) {
                result.put("status", false);
                result.put("message", "Invalid Signature");
                return result;
            }

            Long bookingId = Long.parseLong(bookingIdStr);
            Booking booking = bookingRepository.findById(bookingId).orElse(null);

            if (booking == null) {
                result.put("status", false);
                result.put("message", "Booking not found");
                return result;
            }

            // Lưu PayDate nếu có (để phục vụ hoàn tiền sau này)
            if (vnp_PayDate != null) {
                // Đảm bảo Entity Booking có trường payDate
                 vnp_PayDate = vnp_PayDate;
            }

            // 2. Xử lý trạng thái
            if ("00".equals(vnp_ResponseCode)) {
                // --- BẮT ĐẦU LOGIC FAIL-SAFE ---
                try {
                    // Kiểm tra xem ghế còn trống không (tránh race condition)
                    if (checkSeatsAvailable(bookingId)) {
                        confirmBooking(bookingId); // Cập nhật DB thành công
                        result.put("status", true);
                        result.put("message", "Payment Success");
                    } else {
                        throw new RuntimeException("Ghế đã bị người khác đặt hoặc không hợp lệ");
                    }
                } catch (Exception e) {
                    // LỖI XẢY RA SAU KHI TIỀN ĐÃ TRỪ -> HOÀN TIỀN TỰ ĐỘNG
                    System.err.println("Lỗi xác nhận đơn hàng: " + e.getMessage() + ". Đang hoàn tiền...");

                    String refundMsg = refundTransaction(bookingId, "SYSTEM_AUTO", vnp_PayDate);

                    booking.setStatus(BookingStatus.REFUNDED); // Set trạng thái đã hoàn tiền
                    bookingRepository.save(booking);

                    result.put("status", false);
                    result.put("message", "Lỗi xử lý vé. Hệ thống đã tự động hoàn tiền: " + refundMsg);
                }
                // --- KẾT THÚC LOGIC FAIL-SAFE ---
            } else {
                // Thanh toán thất bại ngay từ đầu
                cancelBooking(bookingId);
                result.put("status", false);
                result.put("message", "Payment Failed or Cancelled");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", false);
            result.put("message", "Internal Server Error: " + e.getMessage());
        }

        return result;
    }

    // =================================================================================
    // 3. HOÀN TIỀN (REFUND TRANSACTION)
    // =================================================================================
    public String refundTransaction(Long bookingId, String userIp, String transactionDate) {
        try {
            Booking booking = bookingRepository.findById(bookingId)
                    .orElseThrow(() -> new RuntimeException("Booking not found"));

            String vnp_RequestId = String.valueOf(System.currentTimeMillis());
            String vnp_Version = "2.1.0";
            String vnp_Command = "refund";
            String vnp_TmnCode = paymentConfig.getVnp_TmnCode();
            String vnp_TransactionType = "02"; // 02: Hoàn toàn phần
            String vnp_TxnRef = String.valueOf(booking.getId());
            String vnp_Amount = String.valueOf((long) (booking.getTotalPrice() * 100));
            String vnp_OrderInfo = "Hoan tien don hang " + booking.getId();
            String vnp_TransactionNo = ""; // Có thể để rỗng

            if (transactionDate == null) {
                // Nếu không có ngày, dùng tạm ngày hiện tại (nhưng đúng ra phải là ngày thanh toán gốc)
                transactionDate = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
            }

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            String vnp_CreateDate = LocalDateTime.now().format(formatter);

            // Tạo Hash Data (Thứ tự các trường BẮT BUỘC của VNPay cho API Refund)
            // requestId|version|command|tmnCode|type|txnRef|amount|txnNo|txnDate|createdBy|createDate|ip|info
            String hash_Data = String.join("|",
                    vnp_RequestId, vnp_Version, vnp_Command, vnp_TmnCode,
                    vnp_TransactionType, vnp_TxnRef, vnp_Amount, vnp_TransactionNo,
                    transactionDate, userIp, vnp_CreateDate, "127.0.0.1", vnp_OrderInfo
            );

            String vnp_SecureHash = paymentConfig.hmacSHA512(paymentConfig.getVnp_HashSecret(), hash_Data);

            JsonObject vnp_Params = new JsonObject();
            vnp_Params.addProperty("vnp_RequestId", vnp_RequestId);
            vnp_Params.addProperty("vnp_Version", vnp_Version);
            vnp_Params.addProperty("vnp_Command", vnp_Command);
            vnp_Params.addProperty("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.addProperty("vnp_TransactionType", vnp_TransactionType);
            vnp_Params.addProperty("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.addProperty("vnp_Amount", vnp_Amount);
            vnp_Params.addProperty("vnp_OrderInfo", vnp_OrderInfo);
            vnp_Params.addProperty("vnp_TransactionDate", transactionDate);
            vnp_Params.addProperty("vnp_CreateBy", userIp);
            vnp_Params.addProperty("vnp_CreateDate", vnp_CreateDate);
            vnp_Params.addProperty("vnp_IpAddr", "127.0.0.1");
            vnp_Params.addProperty("vnp_SecureHash", vnp_SecureHash);

            JsonObject jsonResult = sendVnPayRequest(vnp_Params);

            if (jsonResult != null && jsonResult.has("vnp_ResponseCode")) {
                String responseCode = jsonResult.get("vnp_ResponseCode").getAsString();
                if ("00".equals(responseCode)) {
                    return "SUCCESS";
                } else {
                    return "FAIL: " + jsonResult.get("vnp_Message").getAsString();
                }
            }
            return "FAIL: No response from VNPay";

        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: " + e.getMessage();
        }
    }

    // =================================================================================
    // 4. TRA CỨU TRẠNG THÁI (QUERY DR)
    // =================================================================================
    public String queryVnPayStatus(Long bookingId, LocalDateTime bookingDate) {
        try {
            // 1. Tạo các tham số cơ bản
            String vnp_RequestId = String.valueOf(System.currentTimeMillis());
            String vnp_Version = "2.1.0";
            String vnp_Command = "querydr";
            String vnp_TmnCode = paymentConfig.getVnp_TmnCode();
            String vnp_TxnRef = String.valueOf(bookingId);
            String vnp_OrderInfo = "Kiem tra trang thai don hang " + bookingId;
            // Lưu ý: IP máy bạn đang chạy (localhost) cần đúng với cấu hình trên Sandbox VNPay
            // Nếu chạy local thì thường là 127.0.0.1, nhưng nêú deploy server thì phải là IP Server
            String vnp_IpAddr = "127.0.0.1";

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            String vnp_CreateDate = LocalDateTime.now().format(formatter);
            String vnp_TransDate = bookingDate.format(formatter);

            // 2. Tạo chuỗi Hash (Thứ tự đúng tài liệu QueryDR)
            // requestId|version|command|tmnCode|txnRef|transDate|createDate|ip|info
            String hash_Data = String.join("|",
                    vnp_RequestId, vnp_Version, vnp_Command, vnp_TmnCode,
                    vnp_TxnRef, vnp_TransDate, vnp_CreateDate, vnp_IpAddr,
                    vnp_OrderInfo
            );

            String vnp_SecureHash = PaymentConfig.hmacSHA512(paymentConfig.getVnp_HashSecret(), hash_Data);

            // 3. Build JSON
            JsonObject vnp_Params = new JsonObject();
            vnp_Params.addProperty("vnp_RequestId", vnp_RequestId);
            vnp_Params.addProperty("vnp_Version", vnp_Version);
            vnp_Params.addProperty("vnp_Command", vnp_Command);
            vnp_Params.addProperty("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.addProperty("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.addProperty("vnp_OrderInfo", vnp_OrderInfo);
            vnp_Params.addProperty("vnp_TransactionDate", vnp_TransDate);
            vnp_Params.addProperty("vnp_CreateDate", vnp_CreateDate);
            vnp_Params.addProperty("vnp_IpAddr", vnp_IpAddr);
            vnp_Params.addProperty("vnp_SecureHash", vnp_SecureHash);

            // 4. Gửi Request
            System.out.println("QueryDR Request: " + vnp_Params.toString()); // Log request
            JsonObject jsonResult = sendVnPayRequest(vnp_Params);
            System.out.println("QueryDR Response: " + jsonResult.toString()); // Log response xem nó trả về gì

            // --- BẮT ĐẦU FIX LỖI NULL POINTER ---
            if (jsonResult == null) {
                return "ERROR";
            }

            // Kiểm tra xem có trường vnp_ResponseCode không
            if (jsonResult.has("vnp_ResponseCode")) {
                String responseCode = jsonResult.get("vnp_ResponseCode").getAsString();
                // Một số trường hợp TransactionStatus có thể null nếu lỗi ngay từ đầu
                String transactionStatus = jsonResult.has("vnp_TransactionStatus")
                        ? jsonResult.get("vnp_TransactionStatus").getAsString()
                        : "FAIL";

                if ("00".equals(responseCode) && "00".equals(transactionStatus)) {
                    return "SUCCESS";
                } else {
                    return "FAIL"; // Thanh toán lỗi hoặc chưa thanh toán
                }
            } else {
                // Trường hợp VNPay trả về lỗi dạng khác (ví dụ sai Hash)
                String msg = jsonResult.has("Message") ? jsonResult.get("Message").getAsString() : "Unknown Error";
                System.err.println("VNPay Query Error: " + msg);
                return "ERROR";
            }
            // --- KẾT THÚC FIX ---

        } catch (Exception e) {
            System.err.println("Error querying VNPay status: " + e.getMessage());
            e.printStackTrace();
            return "ERROR";
        }
    }

    // =================================================================================
    // 5. CÁC HÀM HỖ TRỢ (PRIVATE HELPERS)
    // =================================================================================

    // Gửi request POST sang VNPay API
    private JsonObject sendVnPayRequest(JsonObject params) throws Exception {
        URL url = new URL(paymentConfig.getVnp_ApiUrl());
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        try (DataOutputStream wr = new DataOutputStream(connection.getOutputStream())) {
            wr.writeBytes(params.toString());
            wr.flush();
        }

        StringBuilder response = new StringBuilder();
        try (BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
        }
        return JsonParser.parseString(response.toString()).getAsJsonObject();
    }

    // Sắp xếp param và encode URL (Dùng cho tạo Payment Link và Verify Signature)
    private String buildQueryString(Map<String, String> params) {
        List<String> fieldNames = new ArrayList<>(params.keySet());
        Collections.sort(fieldNames);

        StringBuilder query = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = params.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                try {
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                    query.append('=');
                    query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        query.append('&');
                    }
                } catch (Exception e) {
                    throw new RuntimeException("Error encoding URL parameters", e);
                }
            }
        }
        return query.toString();
    }

    // Kiểm tra chữ ký trả về
    private boolean verifyVnPaySignature(Map<String, String> queryParams, String receivedHash) {
        Map<String, String> params = new HashMap<>();
        for (Map.Entry<String, String> entry : queryParams.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();
            if (!key.startsWith("vnp_SecureHash") && value != null && !value.isEmpty()) {
                params.put(key, value);
            }
        }
        String hashData = buildQueryString(params);
        String signValue = paymentConfig.hmacSHA512(paymentConfig.getVnp_HashSecret(), hashData);
        return signValue.equals(receivedHash);
    }

    // Logic kiểm tra ghế (Để đảm bảo ghế chưa bị booked bởi người khác)
    private boolean checkSeatsAvailable(Long bookingId) {
        List<ShowtimeSeat> seats = showtimeSeatRepository.findByBookingId(bookingRepository.findById(bookingId).orElseThrow(() -> new BadRequestException("Ghe da duoc dat"))); // Hàm này phải query theo Booking
        for (ShowtimeSeat seat : seats) {
            // Nếu trạng thái khác HELD (đang giữ chỗ cho mình) và khác AVAILABLE (trống) thì coi như lỗi
            // Tùy logic DB của bạn, ở đây giả sử nếu nó đã bị BOOKED thì return false
            if (seat.getStatus() == SeatStatus.BOOKED) {
                return false;
            }
        }
        return true;
    }

    @Transactional
    public void confirmBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        // Chỉ confirm nếu đơn hàng chưa confirm (Tránh duplicate)
        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            booking.setStatus(BookingStatus.CONFIRMED);
            bookingRepository.save(booking);

            List<ShowtimeSeat> seats = showtimeSeatRepository.findByBookingId(booking);
            seats.forEach(seat -> {
                seat.setStatus(SeatStatus.BOOKED);
                showtimeSeatRepository.save(seat);
            });
            System.out.println("Confirmed Booking ID: " + bookingId);
        }
    }

    @Transactional
    public void cancelBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            booking.setStatus(BookingStatus.CANCELLED);
            bookingRepository.save(booking);

            List<ShowtimeSeat> seats = showtimeSeatRepository.findByBookingId(booking);
            seats.forEach(seat -> {
                seat.setStatus(SeatStatus.AVAILABLE);
                // Gỡ quan hệ Booking khỏi ghế nếu cần thiết
                // seat.setBooking(null);
                showtimeSeatRepository.save(seat);
            });
            System.out.println("Cancelled Booking ID: " + bookingId);
        }
    }
}