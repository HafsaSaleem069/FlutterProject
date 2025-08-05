import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  // Form data
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  int _numberOfGuests = 2;
  bool _isLoading = false;
  String _selectedReservationType = 'High Tea';

  // Page controllers for image scrollers
  final PageController _highTeaPageController = PageController();
  final PageController _dinnerPageController = PageController();
  int _highTeaCurrentPage = 0;
  int _dinnerCurrentPage = 0;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // High Tea Images
  final List<String> _highTeaImages = [
    'https://sdmntpreastus.oaiusercontent.com/files/00000000-5640-61f9-b257-19360a7c95e9/raw?se=2025-07-22T15%3A01%3A46Z&sp=r&sv=2024-08-04&sr=b&scid=661e7755-b6b3-51f0-83fb-2c7455c93181&skoid=31bc9c1a-c7e0-460a-8671-bf4a3c419305&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2025-07-22T12%3A57%3A17Z&ske=2025-07-23T12%3A57%3A17Z&sks=b&skv=2024-08-04&sig=V4cc2XdVH3S3QtETzooXwaTH%2BLOh8aLrUVAvC5H8cKw%3D',
    'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=800&h=400&fit=crop',
  ];

  // Dinner Images
  final List<String> _dinnerImages = [
    'https://sdmntpreastus.oaiusercontent.com/files/00000000-ca7c-61f9-a5cd-76f6e0f039dd/raw?se=2025-07-22T15%3A06%3A05Z&sp=r&sv=2024-08-04&sr=b&scid=6a8195d7-cb85-5076-98a2-9914f3b54b55&skoid=31bc9c1a-c7e0-460a-8671-bf4a3c419305&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2025-07-21T23%3A20%3A59Z&ske=2025-07-22T23%3A20%3A59Z&sks=b&skv=2024-08-04&sig=DzHOdFfQVwW22TkvAlTvrq5oRHmuYpzen/q7uBK1EPQ%3D',
    'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=800&h=400&fit=crop',
  ];

  // Time slots for High Tea (1 PM to 5 PM)
  final List<Map<String, String>> _highTeaSlots = [
    {'time': '1:00 PM - 2:30 PM', 'value': '13:00-14:30'},
    {'time': '2:30 PM - 4:00 PM', 'value': '14:30-16:00'},
    {'time': '4:00 PM - 5:30 PM', 'value': '16:00-17:30'},
  ];

  // Time slots for Dinner (6 PM to 11 PM)
  final List<Map<String, String>> _dinnerSlots = [
    {'time': '6:00 PM - 7:30 PM', 'value': '18:00-19:30'},
    {'time': '7:30 PM - 9:00 PM', 'value': '19:30-21:00'},
    {'time': '9:00 PM - 10:30 PM', 'value': '21:00-22:30'},
    {'time': '10:30 PM - 11:30 PM', 'value': '22:30-23:30'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserDetails();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _highTeaPageController.dispose();
    _dinnerPageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get();

        if (userDoc.exists) {
          setState(() {
            _nameController.text = userDoc.data()?['name'] ?? '';
            _phoneController.text = userDoc.data()?['phone'] ?? '';
            _emailController.text =
                userDoc.data()?['email'] ?? user!.email ?? '';
          });
        }
      } catch (e) {
        print("Error loading user details: $e");
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
      });
    }
  }

  Future<bool> _checkSlotAvailability(DateTime date, String timeSlot) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('reservations')
              .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(date))
              .where('timeSlot', isEqualTo: timeSlot)
              .where('reservationType', isEqualTo: _selectedReservationType)
              .get();

      int totalGuests = 0;
      for (var doc in querySnapshot.docs) {
        totalGuests += (doc.data()['numberOfGuests'] as int? ?? 0);
      }

      return totalGuests < 50;
    } catch (e) {
      print("Error checking availability: $e");
      return false;
    }
  }

  Future<void> _makeReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showSnackBar('Please select a date', isError: true);
      return;
    }
    if (_selectedTimeSlot == null) {
      _showSnackBar('Please select a time slot', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isAvailable = await _checkSlotAvailability(
        _selectedDate!,
        _selectedTimeSlot!,
      );
      if (!isAvailable) {
        _showSnackBar(
          'Selected time slot is fully booked. Please choose another slot.',
          isError: true,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final reservationData = {
        'userId': user?.uid ?? 'guest',
        'customerName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'timeSlot': _selectedTimeSlot!,
        'numberOfGuests': _numberOfGuests,
        'specialRequests': _specialRequestsController.text.trim(),
        'reservationStatus': 'Confirmed',
        'createdAt': FieldValue.serverTimestamp(),
        'reservationType': _selectedReservationType,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('reservations')
          .add(reservationData);

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
              'name': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
              'email': _emailController.text.trim(),
            }, SetOptions(merge: true));
      }

      _showSuccessDialog(docRef.id);
    } catch (e) {
      print("Error making reservation: $e");
      _showSnackBar(
        'Failed to make reservation. Please try again.',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        backgroundColor:
            isError
                ? Colors.red.shade700
                : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog(String reservationId) {
    final currentSlots =
        _selectedReservationType == 'High Tea' ? _highTeaSlots : _dinnerSlots;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Reservation Confirmed!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your $_selectedReservationType reservation has been confirmed.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${reservationId.substring(0, 8).toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate!)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Time: ${currentSlots.firstWhere((slot) => slot['value'] == _selectedTimeSlot)['time']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Guests: $_numberOfGuests • Type: $_selectedReservationType',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
    );
  }

  Widget _buildImageScroller(
    List<String> images,
    PageController controller,
    int currentPage,
    Function(int) onPageChanged,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.inversePrimary.withOpacity(0.2),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.inversePrimary.withOpacity(0.2),
                            child: Icon(
                              Icons.broken_image,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 40,
                            ),
                          );
                        },
                      ),
                      // Gradient overlay for better text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: currentPage == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReservationTypeSection(),
                  const SizedBox(height: 20),
                  _buildDateTimeSection(),
                  const SizedBox(height: 20),
                  _buildGuestSection(),
                  const SizedBox(height: 20),
                  _buildCustomerDetailsSection(),
                  const SizedBox(height: 20),
                  _buildSpecialRequestsSection(),
                  const SizedBox(height: 24),
                  _buildReservationButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Make Reservation',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.tertiary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.inversePrimary.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.tertiary,
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildReservationTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Your Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // High Tea Section
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _selectedReservationType == 'High Tea'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.inversePrimary.withOpacity(0.4),
                width: _selectedReservationType == 'High Tea' ? 2.5 : 1,
              ),
              color:
                  _selectedReservationType == 'High Tea'
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.03)
                      : Colors.transparent,
              boxShadow:
                  _selectedReservationType == 'High Tea'
                      ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // High Tea Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'High Tea Buffet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Popular',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Elegant afternoon tea with premium pastries, finger sandwiches & artisanal teas',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.secondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '1:00 PM - 5:30 PM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReservationType = 'High Tea';
                            _selectedTimeSlot = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _selectedReservationType == 'High Tea'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  _selectedReservationType == 'High Tea'
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.secondary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color:
                                _selectedReservationType == 'High Tea'
                                    ? Colors.white
                                    : Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // High Tea Image Scroller
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildImageScroller(
                    _highTeaImages,
                    _highTeaPageController,
                    _highTeaCurrentPage,
                    (index) {
                      setState(() {
                        _highTeaCurrentPage = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Dinner Section
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _selectedReservationType == 'Dinner'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.inversePrimary.withOpacity(0.4),
                width: _selectedReservationType == 'Dinner' ? 2.5 : 1,
              ),
              color:
                  _selectedReservationType == 'Dinner'
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.03)
                      : Colors.transparent,
              boxShadow:
                  _selectedReservationType == 'Dinner'
                      ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dinner Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dinner Experience',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Premium',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Fine dining experience with curated menu, wine selection & elegant ambiance',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.secondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '6:00 PM - 11:30 PM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReservationType = 'Dinner';
                            _selectedTimeSlot = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _selectedReservationType == 'Dinner'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  _selectedReservationType == 'Dinner'
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.secondary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color:
                                _selectedReservationType == 'Dinner'
                                    ? Colors.white
                                    : Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dinner Image Scroller
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildImageScroller(
                    _dinnerImages,
                    _dinnerPageController,
                    _dinnerCurrentPage,
                    (index) {
                      setState(() {
                        _dinnerCurrentPage = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    final currentTimeSlots =
        _selectedReservationType == 'High Tea' ? _highTeaSlots : _dinnerSlots;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Select Date & Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Selection
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.inversePrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat(
                                'EEEE, MMMM d, yyyy',
                              ).format(_selectedDate!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _selectedDate == null
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Time Slot Selection
          Text(
            'Available Time Slots',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                currentTimeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = slot['value'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                          width: 1.5,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Text(
                        slot['time']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Number of Guests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGuestButton(Icons.remove, () {
                      if (_numberOfGuests > 1) {
                        setState(() {
                          _numberOfGuests--;
                        });
                      }
                    }),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$_numberOfGuests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    _buildGuestButton(Icons.add, () {
                      if (_numberOfGuests < 10) {
                        setState(() {
                          _numberOfGuests++;
                        });
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Maximum 10 guests per reservation',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCustomerDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequestsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.note_add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Special Requests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.secondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialRequestsController,
            maxLines: 3,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText:
                  'Dietary restrictions, allergies, special occasions, seating preferences...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.inversePrimary.withOpacity(0.1),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Theme.of(context).colorScheme.tertiary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.inversePrimary.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
      validator: validator,
    );
  }

  Widget _buildReservationButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _makeReservation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.restaurant_menu, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Confirm Reservation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
