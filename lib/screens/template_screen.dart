import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';

class TemplateScreen extends StatefulWidget {
  static const routeName = '/templates';
  
  const TemplateScreen({Key? key}) : super(key: key);

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  String _selectedTemplate = 'standard';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSelectedTemplate();
  }
  
  Future<void> _loadSelectedTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTemplate = prefs.getString('template') ?? 'standard';
      _isLoading = false;
    });
  }
  
  Future<void> _selectTemplate(String template) async {
    setState(() {
      _selectedTemplate = template;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('template', template);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template updated successfully'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Display Templates')),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translate('Choose a display style for your items'),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Standard Template
                  _buildTemplateOption(
                    context,
                    title: translate('Standard'),
                    description: translate('Default card layout with detailed information'),
                    template: 'standard',
                    icon: Icons.view_agenda,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Compact Template
                  _buildTemplateOption(
                    context,
                    title: translate('Compact'),
                    description: translate('Space-saving layout to see more items at once'),
                    template: 'compact',
                    icon: Icons.view_list,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Grid Template
                  _buildTemplateOption(
                    context,
                    title: translate('Grid'),
                    description: translate('Grid layout with visual focus on images'),
                    template: 'grid',
                    icon: Icons.grid_view,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Calendar Template
                  _buildTemplateOption(
                    context,
                    title: translate('Calendar'),
                    description: translate('View items organized by expiry date in a calendar'),
                    template: 'calendar',
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildTemplateOption(
    BuildContext context, {
    required String title,
    required String description,
    required String template,
    required IconData icon,
  }) {
    final isSelected = _selectedTemplate == template;
    
    return GestureDetector(
      onTap: () => _selectTemplate(template),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}