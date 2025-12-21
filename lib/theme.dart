import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  // --- COLOR CONSTANTS (Refined for Clarity & Contrast) ---
  // const gold = Color(0xFFFFC857); // Primary Gold Accent
  // const darkSurface = Color.fromARGB(255, 30, 30, 30); // Main Background (darkBg)
  // const cardColor = Color.fromARGB(255, 15, 15, 16); // Darker Surface/Card/Dialog
  // const offWhite = Color(0xFFE0E0E0); // Secondary/Muted Text

  const gold = Color(0xFFFFC857); // Primary Gold Accent
  const darkSurface = Color.fromARGB(255, 30, 30, 30); // Main Background (Like Figma Mockup)
  const elevatedCardColor = Color.fromARGB(255, 40, 40, 40);
  const cardColor = Color.fromARGB(255, 15, 15, 16); // Darker Surface/Card/Dialog
  const offWhite = Color(0xFFE0E0E0); // Secondary/Muted Text
  const inputFillColor = Color.fromARGB(255, 45, 45, 45); // NEW: Slightly lighter fill for input fields
  

  final base = ThemeData.dark();
  return base.copyWith(
    primaryColor: gold,
    scaffoldBackgroundColor: darkSurface, // darkBg is now darkSurface
    cardColor: elevatedCardColor, // Used for Card/ListTile backgrounds
    dividerColor: const Color.fromARGB(255, 60, 60, 60),
    dividerTheme: DividerThemeData(
      thickness: 1, color: Color.fromARGB(255, 45, 45, 45),
    ),
    
    colorScheme: base.colorScheme.copyWith(
      primary: gold,
      secondary: gold,
      onSurface: offWhite,
      surface: darkSurface,
    ),
    
    // --- APP BAR THEME ---
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: offWhite,
      elevation: 0, // Subtle elevation
      titleTextStyle: TextStyle(fontSize: 16, color: offWhite),
      iconTheme: IconThemeData(color: offWhite, size: 18),
    ),

    // --- BUTTON THEMES ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold, // Primary CTA is Gold
        foregroundColor: Colors.black87,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Slight adjustment to match input fields
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: offWhite,
        side: const BorderSide(color: Color.fromARGB(255, 69, 69, 69)),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    // outlinedButtonTheme: OutlinedButtonThemeData(
    //   style: OutlinedButton.styleFrom(
    //     foregroundColor: gold, 
    //     side: const BorderSide(color: gold), 
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    //     textStyle: const TextStyle(fontWeight: FontWeight.w500),
    //   ),
    // ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: gold,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: Colors.black87,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),

    // --- INPUT FIELDS ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true, 
      fillColor: inputFillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(color: offWhite.withValues(alpha: 0.8)), // Labels should be off-white unless focused
      hintStyle: TextStyle(color: offWhite.withValues(alpha: 0.5)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), 
        borderSide: const BorderSide(color: Color.fromARGB(255, 60, 60, 60)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), 
        borderSide: const BorderSide(color: gold, width: 1.5), // Thicker border on focus
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(fontSize: 18.0, color: offWhite, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: offWhite),
    ),
    
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: darkSurface,
      collapsedBackgroundColor: darkSurface,
      collapsedIconColor: gold,
      collapsedTextColor: gold,
      iconColor: gold,
      textColor: gold,
      shape: Border.all(color: Colors.transparent), 
      collapsedShape: Border.all(color: Colors.transparent),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: cardColor, // Use darker surface for popups
      elevation: 8, // Slightly higher elevation
      textStyle: const TextStyle(color: offWhite, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Match app rounding
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.6),
    ),
    
    // ListTile Theme for Item Display
    listTileTheme: ListTileThemeData(
      // tileColor: cardColor,
      iconColor: offWhite,
      textColor: offWhite,
      subtitleTextStyle: TextStyle(color: offWhite.withValues(alpha: 0.7)),
    ),

    cardTheme: CardThemeData(
      color: elevatedCardColor,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
              width: 0.5
          )
      )
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: gold
    )
  );
}