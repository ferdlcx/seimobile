import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/data/models/pengguna_model.dart';
import '../../data/models/master_models.dart';

class MasterDataState {
  final List<Toko> tokoList;
  final List<Wilayah> wilayahList;
  final List<Kriteria> kriteriaList;
  final List<Pengguna> salesList;
  final int? filterWilayahId;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? successBanner;

  const MasterDataState({
    this.tokoList = const [],
    this.wilayahList = const [],
    this.kriteriaList = const [],
    this.salesList = const [],
    this.filterWilayahId,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.successBanner,
  });

  MasterDataState copyWith({
    List<Toko>? tokoList,
    List<Wilayah>? wilayahList,
    List<Kriteria>? kriteriaList,
    List<Pengguna>? salesList,
    int? filterWilayahId,
    bool clearFilterWilayah = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successBanner,
    bool clearBanner = false,
  }) {
    return MasterDataState(
      tokoList: tokoList ?? this.tokoList,
      wilayahList: wilayahList ?? this.wilayahList,
      kriteriaList: kriteriaList ?? this.kriteriaList,
      salesList: salesList ?? this.salesList,
      filterWilayahId: clearFilterWilayah
          ? null
          : (filterWilayahId ?? this.filterWilayahId),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successBanner: clearBanner ? null : (successBanner ?? this.successBanner),
    );
  }
}

class MasterDataNotifier extends Notifier<MasterDataState> {
  @override
  MasterDataState build() {
    Future.microtask(() => loadAll());
    return const MasterDataState(isLoading: true);
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final masterRepo = ref.read(masterRepositoryProvider);
      final akunRepo = ref.read(akunRepositoryProvider);

      final results = await Future.wait([
        masterRepo.wilayah(),
        masterRepo.tokoList(
          wilayahId: state.filterWilayahId,
          q: state.searchQuery,
        ),
        masterRepo.kriteria(),
        akunRepo.list(),
      ]);

      final wList = results[0] as List<Wilayah>;
      final tList = results[1] as List<Toko>;
      final kList = results[2] as List<Kriteria>;
      final aList = results[3] as List<Pengguna>;

      final sList = aList.where((a) => a.role != 'admin_tagihan').toList();

      state = state.copyWith(
        wilayahList: wList,
        tokoList: tList,
        kriteriaList: kList,
        salesList: sList,
        isLoading: false,
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  Future<void> filterWilayah(int? wilayahId) async {
    state = state.copyWith(
      filterWilayahId: wilayahId,
      clearFilterWilayah: wilayahId == null,
    );
    await _refreshToko();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await _refreshToko();
  }

  Future<void> _refreshToko() async {
    try {
      final masterRepo = ref.read(masterRepositoryProvider);
      final tList = await masterRepo.tokoList(
        wilayahId: state.filterWilayahId,
        q: state.searchQuery,
      );
      state = state.copyWith(tokoList: tList);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(errorMessage: msg);
    }
  }

  Future<bool> tambahToko({
    required String nama,
    required String noJo,
    required int wilayahId,
    required String alamat,
    String ket = '',
    double? lat,
    double? lng,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearBanner: true);
    try {
      final masterRepo = ref.read(masterRepositoryProvider);
      final baru = await masterRepo.tokoCreate(
        nama: nama,
        noJo: noJo,
        wilayahId: wilayahId,
        alamat: alamat,
        ket: ket,
        lat: lat,
        lng: lng,
      );
      state = state.copyWith(
        tokoList: [...state.tokoList, baru],
        isLoading: false,
        successBanner: 'Data toko "${baru.nama}" (${baru.noJo}) berhasil ditambahkan.',
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  void clearBanner() {
    state = state.copyWith(clearBanner: true);
  }
}

final masterDataProvider =
    NotifierProvider<MasterDataNotifier, MasterDataState>(
  MasterDataNotifier.new,
);
