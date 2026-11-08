import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sukun/utils/perf.dart';

import '../main.dart';

class VideoCallService {
  static Future<void> joinSession({
    required BuildContext context,
    required String appointmentId,
    required String displayName,
    required bool isAnonymous,
  }) async {
    final permissions =
        await [Permission.microphone, Permission.camera].request();
    if (permissions[Permission.microphone] != PermissionStatus.granted ||
        permissions[Permission.camera] != PermissionStatus.granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Camera and microphone permissions required')),
        );
      }
      return;
    }

    final name =
        isAnonymous ? 'Sukun User' : (displayName.isEmpty ? 'User' : displayName);

    try {
      final res = await timeAsync('livekit_token', () => supabase.functions.invoke(
        'livekit-token',
        body: {'appointmentId': appointmentId, 'displayName': name},
      ));

      if (res.data == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not start video session')),
          );
        }
        return;
      }

      final data = res.data as Map<String, dynamic>;
      final serverUrl = data['serverUrl'] as String;
      final token = data['token'] as String;
      final roomKey = data['roomKey'] as String;

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveKitCallScreen(
              serverUrl: serverUrl,
              token: token,
              roomKey: roomKey,
              displayName: name,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start video session')),
        );
      }
    }
  }
}

class LiveKitCallScreen extends StatefulWidget {
  const LiveKitCallScreen({
    super.key,
    required this.serverUrl,
    required this.token,
    required this.roomKey,
    required this.displayName,
  });

  final String serverUrl;
  final String token;
  final String roomKey;
  final String displayName;

  @override
  State<LiveKitCallScreen> createState() => _LiveKitCallScreenState();
}

class _LiveKitCallScreenState extends State<LiveKitCallScreen> {
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  bool _muted = false;
  bool _videoMuted = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    final keyProvider = await BaseKeyProvider.create();
    await keyProvider.setSharedKey(widget.roomKey);

    final room = Room(
      roomOptions: RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        e2eeOptions: E2EEOptions(keyProvider: keyProvider),
      ),
    );

    _listener = room.createListener()
      ..on<TrackSubscribedEvent>((_) {
        if (mounted) setState(() {});
      })
      ..on<TrackUnsubscribedEvent>((_) {
        if (mounted) setState(() {});
      })
      ..on<ParticipantConnectedEvent>((_) {
        if (mounted) setState(() {});
      })
      ..on<ParticipantDisconnectedEvent>((_) {
        if (mounted) setState(() {});
      })
      ..on<TrackMutedEvent>((_) {
        if (mounted) setState(() {});
      })
      ..on<TrackUnmutedEvent>((_) {
        if (mounted) setState(() {});
      });

    await timeAsync('livekit_connect', () => room.connect(widget.serverUrl, widget.token));
    await room.localParticipant?.setCameraEnabled(true);
    await room.localParticipant?.setMicrophoneEnabled(true);

    if (mounted) setState(() => _room = room);
  }

  @override
  void dispose() {
    _listener?.dispose();
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await _room?.localParticipant?.setMicrophoneEnabled(!_muted);
  }

  Future<void> _toggleVideo() async {
    setState(() => _videoMuted = !_videoMuted);
    await _room?.localParticipant?.setCameraEnabled(!_videoMuted);
  }

  Future<void> _switchCamera() async {
    final track = _room?.localParticipant?.videoTrackPublications
        .firstOrNull
        ?.track;
    if (track == null) return;
    final opts = track.currentOptions;
    if (opts is CameraCaptureOptions) {
      await track.setCameraPosition(opts.cameraPosition.switched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    if (room == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6B7E67)),
        ),
      );
    }

    final remote = room.remoteParticipants.values.firstOrNull;
    final remoteTrack = remote?.videoTrackPublications
        .where((p) => !p.muted)
        .firstOrNull
        ?.track;
    final localTrack = room.localParticipant?.videoTrackPublications
        .firstOrNull
        ?.track;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: remoteTrack != null
                  ? VideoTrackRenderer(remoteTrack)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                              color: Color(0xFF6B7E67)),
                          const SizedBox(height: 20),
                          Text(
                            remote != null
                                ? 'Connected — waiting for video...'
                                : 'Waiting for the other person to join...',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
            ),
            if (localTrack != null && !_videoMuted)
              Positioned(
                top: 16,
                right: 16,
                width: 110,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: VideoTrackRenderer(localTrack),
                  ),
                ),
              ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Sukun Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon:
                        _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color: _muted ? Colors.red : Colors.white24,
                    onTap: _toggleMute,
                  ),
                  _ControlButton(
                    icon: _videoMuted
                        ? Icons.videocam_off_rounded
                        : Icons.videocam_rounded,
                    color: _videoMuted ? Colors.red : Colors.white24,
                    onTap: _toggleVideo,
                  ),
                  _ControlButton(
                    icon: Icons.cameraswitch_rounded,
                    color: Colors.white24,
                    onTap: _switchCamera,
                  ),
                  _ControlButton(
                    icon: Icons.call_end_rounded,
                    color: const Color(0xFFE57373),
                    onTap: () {
                      _room?.disconnect();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
