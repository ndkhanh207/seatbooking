package com.cinema.seatbooking.service;


import com.cinema.seatbooking.common.SeatStatus;
import com.cinema.seatbooking.common.SeatType;
import com.cinema.seatbooking.dto.ShowtimeRequest;
import com.cinema.seatbooking.dto.ShowtimeResponse;
import com.cinema.seatbooking.entity.*;
import com.cinema.seatbooking.exception.NotFoundException;
import com.cinema.seatbooking.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class ShowtimeService {
    private final SeatRepository seatRepository;
    private final ShowtimeSeatRepository showtimeSeatRepository;
    ShowtimeRepository showtimeRepo;
    MovieRepository movieRepo;
    RoomRepository roomRepo;

    public ShowtimeService(ShowtimeRepository showtimeRepo, MovieRepository movieRepo, RoomRepository roomRepo, SeatRepository seatRepository, ShowtimeSeatRepository showtimeSeatRepository) {
        this.showtimeRepo = showtimeRepo;
        this.movieRepo = movieRepo;
        this.roomRepo = roomRepo;
        this.seatRepository = seatRepository;
        this.showtimeSeatRepository = showtimeSeatRepository;
    }


    public List<ShowtimeResponse> getShowtimeByMovieId(Long movieId) {
        List<Showtime> listShowtime;
        List<ShowtimeResponse> listShowtimeRespond = new java.util.ArrayList<>();
        listShowtime = showtimeRepo.findShowtimeByMovieId_Id(movieId);
        listShowtime.forEach(showtime -> {
            listShowtimeRespond.add(new ShowtimeResponse(
                    showtime.getId(),
                    showtime.getMovieId().getId(),
                    showtime.getRoomId().getName(),
                    showtime.getStartTime().toString()
            ));
        });
        return listShowtimeRespond;
    }

    @Transactional
    public void addShowtime(ShowtimeRequest request) {
        // Bước 1: Tìm Movie và Room
        Movie movie = movieRepo.findById(request.getMovieId())
                .orElseThrow(() -> new RuntimeException("Movie not found")); // Sửa lại Exception chuẩn
        Room room = roomRepo.findById(request.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room not found"));

        // Bước 2: Tạo và Lưu Showtime trước
        Showtime showtime = new Showtime();
        showtime.setMovieId(movie); // Lưu ý: Tên field trong Entity thường là 'movie', ko phải 'movieId'
        showtime.setRoomId(room);
        showtime.setStartTime(request.getStartTime());
        // ... set các field khác nếu có (ví dụ endTime) ...

        // Quan trọng: Phải save() xong mới có ID để gán cho ghế
        showtime = showtimeRepo.save(showtime);

        // Bước 3: Lấy tất cả ghế cứng của phòng chiếu đó
        List<Seat> seatsInRoom = seatRepository.findSeatByRoomId_Id(room.getId());

        // Bước 4: Tạo danh sách ShowtimeSeat (Ghế bán vé) tương ứng
        List<ShowtimeSeat> showtimeSeatsToSave = new ArrayList<>();

        for (Seat seat : seatsInRoom) {
            ShowtimeSeat showtimeSeat = new ShowtimeSeat();
            showtimeSeat.setShowtimeId(showtime); // Gán vào suất chiếu vừa tạo
            showtimeSeat.setSeatId(seat);         // Gán vào ghế cứng
            showtimeSeat.setStatus(SeatStatus.AVAILABLE); // Trạng thái mặc định là Trống

            // Xử lý giá vé VIP (Logic phụ, nếu cần)
            if (seat.getSeatType() == SeatType.NORMAL) {
                showtimeSeat.setPrice(50000.0);
            } else if (seat.getSeatType() == SeatType.VIP) {
                showtimeSeat.setPrice(75000.0);
            } else {
                showtimeSeat.setPrice(90000.0); // Giá ghế COUPLE
            }

            showtimeSeatsToSave.add(showtimeSeat);
        }

        // Bước 5: Lưu một lần (Save All) cho nhanh
        showtimeSeatRepository.saveAll(showtimeSeatsToSave);
    }
}
