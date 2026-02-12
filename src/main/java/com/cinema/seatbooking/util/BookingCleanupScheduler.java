package com.cinema.seatbooking.util;


import com.cinema.seatbooking.common.BookingStatus;
import com.cinema.seatbooking.entity.Booking;
import com.cinema.seatbooking.repository.BookingRepository;
import com.cinema.seatbooking.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
@EnableScheduling
@RequiredArgsConstructor
public class BookingCleanupScheduler {

    private final BookingRepository bookingRepository;
    private final PaymentService paymentService; // Cần viết thêm hàm queryTransaction tương tự refund ở trên

    // Chạy mỗi 15 phút
    @Scheduled(fixedRate = 900000)
    public void processPendingBookings() {
        // 1. Lấy các đơn PENDING đã tạo quá 15 phút
        LocalDateTime cutOffTime = LocalDateTime.now().minusMinutes(15);
        List<Booking> stuckBookings = bookingRepository.findByStatusAndBookingDateBefore(BookingStatus.PENDING, cutOffTime);

        for (Booking booking : stuckBookings) {
            // 2. Gọi API truy vấn sang VNPay (QueryDR) xem đơn này thực tế đã trả tiền chưa
            String vnpayStatus = paymentService.queryVnPayStatus(booking.getId(), booking.getBookingDate());

            if ("SUCCESS".equals(vnpayStatus)) {
                // Khách đã trả tiền mà mình chưa update -> Update ngay
                paymentService.confirmBooking(booking.getId());
                System.out.println("Đã update đơn hàng: " + booking.getId());
            } else {
                // Khách chưa trả hoặc hủy -> Hủy đơn, nhả ghế
                paymentService.cancelBooking(booking.getId());
                System.out.println("Đã hủy đơn treo: " + booking.getId());
            }
        }
    }
}