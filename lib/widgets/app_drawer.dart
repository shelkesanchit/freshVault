import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/language_screen.dart';
import '../screens/template_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/data_management_screen.dart';
import '../screens/shopping_list_screen.dart';
import '../screens/barcode_scanner_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/bulk_operations_screen.dart';
import '../screens/login_screen.dart';
import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.access_time,
                      size: 36,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      translate('FreshVault'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      translate('Manage your expiry dates'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      '${translate('User')}: ${userProvider.currentUserLogin}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: translate('Home'),
                  route: HomeScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today,
                  title: translate('Calendar View'),
                  route: CalendarScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.category,
                  title: translate('Categories'),
                  route: CategoriesScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: translate('Scan Barcode'),
                  route: BarcodeScannerScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_cart,
                  title: translate('Shopping List'),
                  route: ShoppingListScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  title: translate('Statistics'),
                  route: StatsScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.grid_view,
                  title: translate('Display Templates'),
                  route: TemplateScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.batch_prediction,
                  title: translate('Bulk Operations'),
                  route: BulkOperationsScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.data_usage,
                  title: translate('Data Management'),
                  route: DataManagementScreen.routeName,
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.language,
                  title: translate('Language'),
                  route: LanguageScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: translate('Settings'),
                  route: SettingsScreen.routeName,
                ),
                
                // Theme toggle
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: Text(themeProvider.isDarkMode ? translate('Dark Mode') : translate('Light Mode')),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                
                // Logout option
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(translate('Logout')),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(translate('Confirm Logout')),
                        content: Text(translate('Are you sure you want to logout?')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(translate('Cancel')),
                          ),
                          TextButton(
                            onPressed: () {
                              authProvider.logout().then((_) {
                                Navigator.of(ctx).pop();
                                Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                              });
                            },
                            child: Text(
                              translate('Logout'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                Flexible(
                  child: Text(
                    '${translate('Version')} 1.0.0',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(userProvider.currentDateTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    translate('Developed by Sanchit Shelke'),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = ModalRoute.of(context)?.settings.name == route;
    
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor.withOpacity(0.15) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : null,
            color: isActive ? Theme.of(context).primaryColor : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.of(context).pushReplacementNamed(route);
        },
      ),
    );
  }
}