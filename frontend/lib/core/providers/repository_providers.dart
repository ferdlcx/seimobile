import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/admin_akun/data/akun_repository.dart';
import '../../features/admin_akun/data/api_akun_repository.dart';
import '../../features/admin_akun/data/mock_akun_repository.dart';
import '../../features/admin_data/data/api_master_repository.dart';
import '../../features/admin_data/data/master_repository.dart';
import '../../features/admin_data/data/mock_master_repository.dart';
import '../../features/auth/data/api_auth_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/kondite/data/api_kondite_repository.dart';
import '../../features/kondite/data/kondite_repository.dart';
import '../../features/kondite/data/mock_kondite_repository.dart';
import '../../features/kunjungan/data/api_jurnal_repository.dart';
import '../../features/kunjungan/data/jurnal_repository.dart';
import '../../features/kunjungan/data/mock_jurnal_repository.dart';
import '../../features/laporan/data/api_laporan_repository.dart';
import '../../features/laporan/data/laporan_repository.dart';
import '../../features/laporan/data/mock_laporan_repository.dart';
import '../../features/mapping/data/api_mapping_repository.dart';
import '../../features/mapping/data/mapping_repository.dart';
import '../../features/mapping/data/mock_mapping_repository.dart';
import '../../features/monitoring/data/api_monitoring_repository.dart';
import '../../features/monitoring/data/mock_monitoring_repository.dart';
import '../../features/monitoring/data/monitoring_repository.dart';
import '../../features/reschedule/data/api_reschedule_repository.dart';
import '../../features/reschedule/data/mock_reschedule_repository.dart';
import '../../features/reschedule/data/reschedule_repository.dart';
import '../config/app_config.dart';
import '../mock/mock_database.dart';
import '../network/dio_client.dart';

/// Flag tunggal penentu apakah aplikasi memakai Mock atau API backend.
/// Mengambil default dari `AppConfig.useMock` (default `true`).
const bool useMock = AppConfig.useMock;

/// Provider database in-memory bersama untuk semua MockRepository.
final mockDatabaseProvider = Provider<MockDatabase>((ref) {
  return MockDatabase(getConfig: () => ref.read(appConfigProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (useMock) return MockAuthRepository(ref.watch(mockDatabaseProvider));
  return ApiAuthRepository(ref.watch(dioClientProvider));
});

final akunRepositoryProvider = Provider<AkunRepository>((ref) {
  if (useMock) return MockAkunRepository(ref.watch(mockDatabaseProvider));
  return ApiAkunRepository(ref.watch(dioClientProvider));
});

final masterRepositoryProvider = Provider<MasterRepository>((ref) {
  if (useMock) return MockMasterRepository(ref.watch(mockDatabaseProvider));
  return ApiMasterRepository(ref.watch(dioClientProvider));
});

final mappingRepositoryProvider = Provider<MappingRepository>((ref) {
  if (useMock) return MockMappingRepository(ref.watch(mockDatabaseProvider));
  return ApiMappingRepository(ref.watch(dioClientProvider));
});

final jurnalRepositoryProvider = Provider<JurnalRepository>((ref) {
  if (useMock) return MockJurnalRepository(ref.watch(mockDatabaseProvider));
  return ApiJurnalRepository(ref.watch(dioClientProvider));
});

final monitoringRepositoryProvider = Provider<MonitoringRepository>((ref) {
  if (useMock) return MockMonitoringRepository(ref.watch(mockDatabaseProvider));
  return ApiMonitoringRepository(ref.watch(dioClientProvider));
});

final rescheduleRepositoryProvider = Provider<RescheduleRepository>((ref) {
  if (useMock) return MockRescheduleRepository(ref.watch(mockDatabaseProvider));
  return ApiRescheduleRepository(ref.watch(dioClientProvider));
});

final konditeRepositoryProvider = Provider<KonditeRepository>((ref) {
  if (useMock) return MockKonditeRepository(ref.watch(mockDatabaseProvider));
  return ApiKonditeRepository(ref.watch(dioClientProvider));
});

final laporanRepositoryProvider = Provider<LaporanRepository>((ref) {
  if (useMock) return MockLaporanRepository(ref.watch(mockDatabaseProvider));
  return ApiLaporanRepository(ref.watch(dioClientProvider));
});
