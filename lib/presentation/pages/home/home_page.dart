import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';



import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';

import 'package:knowme/features/astrology/domain/astrology_generation_status.dart';

import 'package:knowme/features/astrology/presentation/astrology_center_routes.dart';

import 'package:knowme/features/funnel_telemetry/funnel_telemetry.dart';

import 'package:knowme/features/home_cohesion/application/home_v2_assembler.dart';
import 'package:knowme/features/home_cohesion/application/home_v2_loader.dart';

import 'package:knowme/features/home_cohesion/application/home_v3_assembler.dart';

import 'package:knowme/features/home_cohesion/application/home_v3_loader.dart';

import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v2_models.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3.dart';

import 'package:knowme/features/home_cohesion/presentation/home_v35_design.dart';

import 'package:knowme/features/home_cohesion/presentation/home_screen_v3_models.dart';

import 'package:knowme/features/tests/big_five/big_five_routes.dart';

import 'package:knowme/features/tests/eq/eq_routes.dart';

import 'package:knowme/features/tests/fusion/fusion_routes.dart';

import 'package:knowme/features/tests/mbti/mbti_routes.dart';



import '../../providers/auth_provider.dart';

import '../astrology/astrology_result_page.dart';

import '../bazi/bazi_result_page.dart';

import '../profile/edit_profile_page_v1.dart';



class HomePage extends StatefulWidget {

  const HomePage({super.key});



  @override

  State<HomePage> createState() => _HomePageState();

}



class _HomePageState extends State<HomePage> {

  final _homeLoader = HomeV3Loader();

  final _generationCoordinator = AstrologyGenerationCoordinator();

  HomeScreenV3Data? _homeData;

  HomeV2SourceBundle? _sourceBundle;

  NarrativeResult? _narrativeResult;

  AstrologyGenerationSnapshot? _generationSnapshot;

  bool _shellLoading = true;

  bool _narrativeLoading = false;



  @override

  void initState() {

    super.initState();

    _homeData = HomeScreenV3Data.empty();

    _loadHome();

    FunnelTelemetry.track(FunnelTelemetryEvent.homeView);

  }



  HomeScreenV3Data _assembleHome({

    required HomeV2SourceBundle bundle,

    NarrativeResult? narrative,

    AstrologyGenerationSnapshot? generation,

  }) {

    return HomeV3Assembler.fromSources(

      bundle,

      narrativeResult: narrative ?? _narrativeResult,

      generation: generation ?? _generationSnapshot,

    );

  }



  Future<void> _loadHome() async {

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final preserveVisibleShell = _homeData != null;

    setState(() {

      _shellLoading = !preserveVisibleShell;

      _narrativeLoading = uid.isNotEmpty;

    });



    final result = await _homeLoader.loadProgressive(

      uid,

      onShellReady: (shell, bundle) {

        if (!mounted) return;

        _sourceBundle = bundle;

        setState(() {

          _homeData = _assembleHome(bundle: bundle);

          _shellLoading = false;

        });

        _runAutoGeneration(uid, bundle);

      },

    );



    if (!mounted) return;

    _sourceBundle = result.bundle;

    _narrativeResult = result.narrative;

    setState(() {

      _homeData = _assembleHome(bundle: result.bundle);

      _shellLoading = false;

      _narrativeLoading = false;

    });

  }



  Future<void> _runAutoGeneration(String uid, HomeV2SourceBundle bundle) async {

    if (uid.isEmpty) return;

    final snapshot = await _generationCoordinator.ensureGenerated(

      uid,

      onProgress: (generation) {

        if (!mounted) return;

        _generationSnapshot = generation;

        setState(() {

          _homeData = _assembleHome(

            bundle: _sourceBundle ?? bundle,

            generation: generation,

          );

        });

      },

    );

    if (!mounted) return;

    _generationSnapshot = snapshot;

    final freshBundle = await HomeV2Loader().loadBundle(uid);

    if (!mounted) return;

    _sourceBundle = freshBundle;

    setState(() {

      _homeData = _assembleHome(

        bundle: freshBundle,

        generation: snapshot,

      );

    });

  }



  void _reloadHome() {

    _loadHome();

  }



  void _openEditProfilePage(BuildContext context) {

    Navigator.push(

      context,

      MaterialPageRoute(builder: (_) => const EditProfilePageV1()),

    ).then((_) {

      if (mounted) _reloadHome();

    });

  }



  Future<void> _logout(BuildContext context) async {

    await context.read<AuthProvider>().logout();

  }



  void _openAstrologyCenter(BuildContext context) {

    AstrologyCenterRoutes.open(context);

  }



  void _openFullInsight(BuildContext context) {

    FusionRoutes.openResult(context);

  }



  void _openUnlockDeepProfile(BuildContext context) {

    FunnelTelemetry.track(FunnelTelemetryEvent.mbtiStart);

    Navigator.of(context).push(MbtiRoutes.miniTestRoute()).then((_) {

      if (mounted) _reloadHome();

    });

  }



  void _openContinueDiscovering(BuildContext context) {

    FusionRoutes.openResult(context);

  }



  void _openPsychologyTest(

    BuildContext context,

    HomePsychologyTestItemData test,

  ) {

    switch (test.id) {

      case 'mbti':

        FunnelTelemetry.track(FunnelTelemetryEvent.mbtiStart);

        Navigator.of(context).push(MbtiRoutes.miniTestRoute()).then((_) {

          if (mounted) _reloadHome();

        });

      case 'eq':

        FunnelTelemetry.track(FunnelTelemetryEvent.eqStart);

        if (test.status == HomePsychologyTestStatus.completed) {

          Navigator.of(context).push(EqRoutes.summary());

        } else {

          Navigator.of(context).push(EqRoutes.home());

        }

      case 'big_five':

        FunnelTelemetry.track(FunnelTelemetryEvent.bigFiveStart);

        BigFiveRoutes.openTest(context);

      default:

        break;

    }

  }



  void _openMoreItem(BuildContext context, HomeMoreItemData item) {

    switch (item.id) {

      case 'fusion':

        _openFullInsight(context);

      case 'profile':

        _openEditProfilePage(context);

      case 'settings':

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(content: Text('การตั้งค่าจะเปิดใช้งานเร็ว ๆ นี้')),

        );

      default:

        break;

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: HomeV35Design.background,

      appBar: AppBar(

        backgroundColor: HomeV35Design.background,

        elevation: 0,

        scrolledUnderElevation: 0,

        automaticallyImplyLeading: false,

        title: const Text(

          'KnowMe',

          style: TextStyle(fontWeight: FontWeight.w700),

        ),

        actions: [

          TextButton(

            onPressed: () => _logout(context),

            child: const Text('ออกจากระบบ'),

          ),

        ],

      ),

      body: SafeArea(

        child: _buildBody(context),

      ),

    );

  }



  Widget _buildBody(BuildContext context) {

    final data = _homeData ?? HomeScreenV3Data.empty();



    return SingleChildScrollView(

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          HomeScreenV3(

            data: data,

            callbacks: HomeScreenV3Callbacks(

              onViewAstrologyResult: () => _openAstrologyCenter(context),

              onViewFullInsight: () => _openFullInsight(context),

              onEditProfile: () => _openEditProfilePage(context),

              onPsychologyTest: (test) => _openPsychologyTest(context, test),

              onUnlockDeepProfile: () => _openUnlockDeepProfile(context),

              onContinueDiscovering: () => _openContinueDiscovering(context),

              narrativeLoading: _narrativeLoading,

              onOpenAstrologyCenter: () => _openAstrologyCenter(context),

            ),

          ),

          if (kDebugMode) ...[

            const SizedBox(height: 28),

            ElevatedButton(

              onPressed: () => Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) => const AstrologyResultPage(),

                ),

              ),

              child: const Text('Open Astrology Result (QA)'),

            ),

            const SizedBox(height: 12),

            ElevatedButton(

              onPressed: () => Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) => const BaziResultPage(),

                ),

              ),

              child: const Text('Open BaZi Result (QA)'),

            ),

          ],

        ],

      ),

    );

  }

}

