import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class MotivationDialog extends StatefulWidget {
  const MotivationDialog({super.key});

  @override
  State<MotivationDialog> createState() => _MotivationDialogState();
}

class _MotivationDialogState extends State<MotivationDialog> {
  String quote = '';
  String author = '';
  bool isLoading = true;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _checkInternetAndFetch() async {
    if (!await InternetConnection().hasInternetAccess) {
      setState(() {
        hasInternet = false;
        isLoading = false;
      });
      return;
    }

    setState(() {
      hasInternet = true;
      isLoading = true;
    });

    await _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=en'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          quote = data['quoteText']?.toString().trim() ?? '';
          author = data['quoteAuthor']?.toString().trim() ?? 'Unknown';
          // Remove extra whitespace and clean up the quote
          if (quote.isNotEmpty) {
            quote = quote.replaceAll(RegExp(r'\s+'), ' ').trim();
            // Remove trailing period if it exists
            if (quote.endsWith('.')) {
              quote = quote.substring(0, quote.length - 1);
            }
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      setState(() {
        quote = 'Failed to load quote';
        author = '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: scheme.surface,
      elevation: 8,
      contentPadding: const EdgeInsets.all(16),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.secondary,
            ],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_quote,
              color: scheme.onPrimary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Random Quote',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 150,
            maxHeight: MediaQuery.of(context).size.height * 0.4,
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: !hasInternet
                ? _buildNoInternetContent(scheme, textTheme)
                : isLoading
                ? _buildLoadingContent(scheme, textTheme)
                : _buildQuoteContent(scheme, textTheme),
          ),
        ),
      ),
      actions: [
        if (!hasInternet)
          _buildActionButton(
            context: context,
            scheme: scheme,
            textTheme: textTheme,
            icon: Icons.refresh,
            label: 'Refresh',
            onTap: _checkInternetAndFetch,
          )
        else ...[
          _buildActionButton(
            context: context,
            scheme: scheme,
            textTheme: textTheme,
            icon: Icons.refresh,
            label: 'New Quote',
            onTap: _checkInternetAndFetch,
          ),
        ],
      ],
    );
  }

  Widget _buildNoInternetContent(ColorScheme scheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.wifi_off,
          size: 48,
          color: scheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'No Internet Connection',
          style: textTheme.titleMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Text(
          'Please check your internet connection and try again.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildLoadingContent(ColorScheme scheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading inspiration...',
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuoteContent(ColorScheme scheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.format_quote,
          size: 32,
          color: scheme.primary,
        ),
        const SizedBox(height: 16),
        Flexible(
          child: Text(
            quote,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: scheme.onSurface,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.fade,
            maxLines: 8,
          ),
        ),
        if (author.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              '— $author',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.primary,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ColorScheme scheme,
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: scheme.primary.withValues(alpha: 0.1),
        foregroundColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: scheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}