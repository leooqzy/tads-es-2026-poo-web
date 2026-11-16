import '../models/admin_dashboard.dart';
import '../repositories/admin_dashboard_repository.dart';

class AdminDashboardService {
  AdminDashboardService(this._repository);

  final AdminDashboardRepository _repository;

  Future<AdminDashboard> getDashboard() {
    return _repository.getDashboard();
  }
}
