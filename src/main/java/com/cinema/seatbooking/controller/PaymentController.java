package com.cinema.seatbooking.controller;

import com.cinema.seatbooking.dto.ApiResponse;
import com.cinema.seatbooking.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/payment")
@RequiredArgsConstructor // Tự động Inject PaymentService (Lombok)
public class PaymentController {

    private final PaymentService paymentService;

    // API 1: Tạo Link
    @GetMapping("/create-payment")
    public ApiResponse<String> createPayment(HttpServletRequest request, @RequestParam Long bookingId) {
        try {
            String paymentUrl = paymentService.createVnPayPayment(bookingId, request);
            return ApiResponse.ok(paymentUrl);
        } catch (Exception e) {
            return ApiResponse.error(("Lỗi tạo thanh toán: " + e.getMessage()));
        }
    }

    // API 2: Xử lý Callback
    @GetMapping("/vnpay-callback")
    public ApiResponse<String> paymentCallback(@RequestParam Map<String, String> queryParams) {
        Map<String, Object> result = paymentService.processVnPayCallback(queryParams);

        boolean isSuccess = (boolean) result.get("status");
        if (isSuccess) {
            // Redirect về trang Success (Frontend) hoặc trả về JSON
            return ApiResponse.ok(result.get("message").toString());
        } else {
            return ApiResponse.error(result.get("message").toString());
        }
    }
}