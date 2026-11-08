import 'dart:async';

import 'package:flutter/material.dart';

import '../models/track.dart';
import '../services/jamendo_service.dart';
import '../services/player_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Track> _results = [];
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q));
  }

  Future<void> _search(String q) async {
    q = q.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
        _lastQuery = '';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = q;
    });
    try {
      final r = await JamendoService.search(q);
      if (!mounted || q != _lastQuery) return;
      setState(() {
        _results = r;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal mencari. Cek koneksi internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              children: [
                const Icon3D(Icons.search_rounded, size: 18, colors: JP.gradCyan),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: _onChanged,
                    onSubmitted: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari lagu, artis, atau album',
                      filled: true,
                      fillColor: JP.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      suffixIcon: _ctrl.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _ctrl.clear();
                                _search('');
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: JP.pink));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.white60)));
    }
    if (_lastQuery.isEmpty) {
      return const Center(
        child: Text('Ketik untuk mulai mencari musik',
            style: TextStyle(color: Colors.white38)),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text('Tidak ada hasil', style: TextStyle(color: Colors.white38)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _results.length,
      itemBuilder: (context, i) => TrackTile(
        track: _results[i],
        onTap: () => PlayerService.instance.playList(_results, i),
      ),
    );
  }
}
