class Cinema {
  final int id;
  final String name;
  final String location;
  final String address;
  final double distance; // in km

  const Cinema({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.distance,
  });
}

class Showtime {
  final String time;
  final String format; // 2D, 3D, IMAX
  final double price;
  final bool isAvailable;

  const Showtime({
    required this.time,
    required this.format,
    required this.price,
    this.isAvailable = true,
  });
}

// Sample data
const sampleCinemas = [
  Cinema(
    id: 1,
    name: 'CGV Vincom',
    location: 'District 1',
    address: '72 Le Thanh Ton, Ben Nghe Ward',
    distance: 2.5,
  ),
  Cinema(
    id: 2,
    name: 'Lotte Cinema',
    location: 'District 3',
    address: '469 Nguyen Thi Minh Khai',
    distance: 3.8,
  ),
  Cinema(
    id: 3,
    name: 'Galaxy Cinema',
    location: 'District 7',
    address: 'Crescent Mall, Nguyen Van Linh',
    distance: 8.2,
  ),
  Cinema(
    id: 4,
    name: 'BHD Star',
    location: 'District 2',
    address: 'Vincom Mega Mall, Xa Lo Ha Noi',
    distance: 12.5,
  ),
];

const sampleShowtimes = [
  Showtime(time: '10:00', format: '2D', price: 100000),
  Showtime(time: '12:30', format: '2D', price: 120000),
  Showtime(time: '15:00', format: '3D', price: 150000),
  Showtime(time: '17:30', format: '2D', price: 120000),
  Showtime(time: '20:00', format: 'IMAX', price: 180000),
  Showtime(time: '22:30', format: '2D', price: 100000, isAvailable: false),
];
