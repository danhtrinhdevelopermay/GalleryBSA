import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/vehicle_grid.dart';
import '../widgets/search_bar_widget.dart';
import '../services/database_service.dart';
import '../models/vehicle.dart';
import 'vehicle_detail_screen.dart';
import 'add_vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedMake = '';
  int _selectedYear = 0;
  
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVehicles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicles = await _databaseService.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
        _filteredVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vehicles: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterVehicles() {
    List<Vehicle> filtered = _vehicles;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        return vehicle.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               vehicle.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               vehicle.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by make
    if (_selectedMake.isNotEmpty) {
      filtered = filtered.where((vehicle) => vehicle.make == _selectedMake).toList();
    }

    // Filter by year
    if (_selectedYear > 0) {
      filtered = filtered.where((vehicle) => vehicle.year == _selectedYear).toList();
    }

    // Filter by status based on selected tab
    switch (_selectedIndex) {
      case 1: // Available
        filtered = filtered.where((vehicle) => vehicle.status == 'available').toList();
        break;
      case 2: // In Use
        filtered = filtered.where((vehicle) => vehicle.status == 'in-use').toList();
        break;
      case 3: // Maintenance
        filtered = filtered.where((vehicle) => vehicle.status == 'maintenance').toList();
        break;
      default: // All
        break;
    }

    setState(() {
      _filteredVehicles = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterVehicles();
  }

  void _onMakeFilterChanged(String make) {
    setState(() {
      _selectedMake = make;
    });
    _filterVehicles();
  }

  void _onYearFilterChanged(int year) {
    setState(() {
      _selectedYear = year;
    });
    _filterVehicles();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedMake = '';
      _selectedYear = 0;
    });
    _filterVehicles();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _filterVehicles();
  }

  void _navigateToVehicleDetail(Vehicle vehicle) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => VehicleDetailScreen(vehicle: vehicle),
      ),
    ).then((_) => _loadVehicles()); // Refresh when coming back
  }

  void _navigateToAddVehicle() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const AddVehicleScreen(),
      ),
    ).then((_) => _loadVehicles()); // Refresh when coming back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Vehicle Gallery',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                centerTitle: true,
              ),
              actions: [
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  onPressed: _navigateToAddVehicle,
                  child: const Icon(
                    CupertinoIcons.add,
                    size: 28,
                  ),
                ),
              ],
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBarWidget(
                  vehicles: _vehicles,
                  onSearchChanged: _onSearchChanged,
                  onMakeFilterChanged: _onMakeFilterChanged,
                  onYearFilterChanged: _onYearFilterChanged,
                  onClearFilters: _clearFilters,
                  searchQuery: _searchQuery,
                  selectedMake: _selectedMake,
                  selectedYear: _selectedYear,
                ),
              ),
            ),
            
            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  onTap: _onTabChanged,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Available'),
                    Tab(text: 'In Use'),
                    Tab(text: 'Maintenance'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 20),
              )
            : _filteredVehicles.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadVehicles,
                    child: VehicleGrid(
                      vehicles: _filteredVehicles,
                      onVehicleTap: _navigateToVehicleDetail,
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.car_detailed,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedMake.isNotEmpty || _selectedYear > 0
                ? 'No vehicles found'
                : 'No vehicles yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedMake.isNotEmpty || _selectedYear > 0
                ? 'Try adjusting your filters'
                : 'Add your first vehicle to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _searchQuery.isNotEmpty || _selectedMake.isNotEmpty || _selectedYear > 0
                ? _clearFilters
                : _navigateToAddVehicle,
            child: Text(
              _searchQuery.isNotEmpty || _selectedMake.isNotEmpty || _selectedYear > 0
                  ? 'Clear Filters'
                  : 'Add Vehicle',
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}