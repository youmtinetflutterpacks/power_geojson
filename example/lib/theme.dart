import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Brand Color Palette ─────────────────────────────────────────────────────

const Color kBackground = Color(0xFF0D1117);
const Color kSurface = Color(0xFF161B22);
const Color kPrimary = Color(0xFF027DFD);
const Color kPolygonFill = Color(0x662195F3); // #2195F3 @ 40%
const Color kPolygonBorder = Color(0xFF1E00FD);
const Color kPolyline = Color(0xFFFF9800);
const Color kMarker = Color(0xFFF44336);
const Color kIndigo = Color(0xFF3F51B5);
const Color kTextPrimary = Color(0xFFE6EDF3);
const Color kTextSecondary = Color(0xFF8B949E);

// ─── Theme ───────────────────────────────────────────────────────────────────

ThemeData appTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.dark(
      surface: kSurface,
      primary: kPrimary,
      onPrimary: Colors.white,
      onSurface: kTextPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: kTextPrimary,
      ),
      iconTheme: const IconThemeData(color: kTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: kSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: kTextPrimary, displayColor: kTextPrimary),
  );
}

// ─── Typography helpers ──────────────────────────────────────────────────────

TextStyle monoStyle({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w500,
  Color color = kTextPrimary,
}) => GoogleFonts.jetBrainsMono(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
);
