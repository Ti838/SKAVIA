/// Default design mock fallbacks matching SKAVIA reference board screens 10 & 12
class ProjectFallbackData {
  static const List<Map<String, dynamic>> fallbackMembers = [
    {
      'name': 'You',
      'role': 'Team Leader',
      'isLeader': true,
      'avatar':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    },
    {
      'name': 'Arafat',
      'role': 'Developer',
      'isLeader': false,
      'avatar':
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
    },
    {
      'name': 'Nusrat',
      'role': 'Designer',
      'isLeader': false,
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    },
    {
      'name': 'Sabbir',
      'role': 'Developer',
      'isLeader': false,
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
  ];

  static const List<Map<String, dynamic>> fallbackTasks = [
    {
      'id': 't1',
      'title': 'Setup project structure',
      'status': 'Completed',
      'date': 'Apr 20',
    },
    {
      'id': 't2',
      'title': 'Design UI components',
      'status': 'In Progress',
      'date': 'Apr 22',
    },
    {
      'id': 't3',
      'title': 'Implement authentication',
      'status': 'Pending',
      'date': 'Apr 25',
    },
    {
      'id': 't4',
      'title': 'API integration',
      'status': 'Pending',
      'date': 'Apr 28',
    },
    {
      'id': 't5',
      'title': 'Testing & bug fix',
      'status': 'Pending',
      'date': 'May 2',
    },
  ];
}

