(function () {
  'use strict';

  var API_BASE = localStorage.getItem('ws_api_base') || 'http://localhost/saftey/backend/api';

  angular.module('wsAdmin', []).config([
    '$httpProvider',
    function ($httpProvider) {
      $httpProvider.interceptors.push([
        '$q',
        function ($q) {
          return {
            request: function (config) {
              var t = localStorage.getItem('ws_admin_token');
              if (t) {
                config.headers = config.headers || {};
                config.headers.Authorization = 'Bearer ' + t;
              }
              return config;
            },
            responseError: function (rejection) {
              if (rejection.status === 401) {
                localStorage.removeItem('ws_admin_token');
              }
              return $q.reject(rejection);
            },
          };
        },
      ]);
    },
  ]);

  angular.module('wsAdmin').controller('MainCtrl', [
    '$scope',
    '$http',
    function ($scope, $http) {
      $scope.apiBase = API_BASE;
      $scope.token = localStorage.getItem('ws_admin_token');
      $scope.view = $scope.token ? 'dashboard' : 'login';
      $scope.loginForm = { username: '', password: '' };
      $scope.err = '';
      $scope.stations = [];
      $scope.deletedStations = [];
      $scope.officers = [];
      $scope.deletedOfficers = [];
      $scope.complaints = [];
      $scope.sosAlerts = [];
      $scope.users = [];
      $scope.navItems = [
        { key: 'dashboard', label: 'Overview', icon: 'bi-grid-1x2-fill' },
        { key: 'stations', label: 'Stations', icon: 'bi-buildings-fill' },
        { key: 'officers', label: 'Officers', icon: 'bi-person-badge-fill' },
        { key: 'complaints', label: 'Complaints', icon: 'bi-journal-richtext' },
        { key: 'sos', label: 'SOS Alerts', icon: 'bi-broadcast-pin' },
        { key: 'users', label: 'Users', icon: 'bi-people-fill' },
      ];
      $scope.moduleCount = function (key) {
        if (key === 'stations') return ($scope.stations && $scope.stations.length) || 0;
        if (key === 'officers') return ($scope.officers && $scope.officers.length) || 0;
        if (key === 'users') return ($scope.users && $scope.users.length) || 0;
        if (key === 'complaints') return ($scope.complaints && $scope.complaints.length) || 0;
        if (key === 'sos') return ($scope.sosAlerts && $scope.sosAlerts.length) || 0;
        return 0;
      };

      $scope.activeNav = function (key) {
        if ($scope.view === 'stationForm') return key === 'stations';
        if ($scope.view === 'officerForm') return key === 'officers';
        return $scope.view === key;
      };

      $scope.pageMetaFor = function (view) {
        var map = {
          dashboard: {
            title: 'Command Overview',
            subtitle: 'Track the pulse of the platform with elevated metrics, quick actions, and a cleaner response-focused layout.',
            actionLabel: '',
            actionIcon: '',
            action: angular.noop,
          },
          stations: {
            title: 'Police Stations',
            subtitle: 'Manage station locations, contact details, and jurisdiction coverage inside a more polished operations table.',
            actionLabel: 'Add Station',
            actionIcon: 'bi-plus-circle',
            action: function () { $scope.editStation(null); },
          },
          stationForm: {
            title: 'Station Editor',
            subtitle: 'Create or update station information with a streamlined form designed for faster data entry.',
            actionLabel: 'Back to Stations',
            actionIcon: 'bi-arrow-left-circle',
            action: function () { $scope.go('stations'); },
          },
          officers: {
            title: 'Officer Directory',
            subtitle: 'Keep officer records organized with better scanning, clearer hierarchy, and easy edit actions.',
            actionLabel: 'Add Officer',
            actionIcon: 'bi-plus-circle',
            action: function () { $scope.editOfficer(null); },
          },
          officerForm: {
            title: 'Officer Editor',
            subtitle: 'Assign station details, profile information, and credentials in one focused edit screen.',
            actionLabel: 'Back to Officers',
            actionIcon: 'bi-arrow-left-circle',
            action: function () { $scope.go('officers'); },
          },
          complaints: {
            title: 'Complaint Monitor',
            subtitle: 'Review complaint flow with filters, stronger status badges, and a dashboard-style presentation.',
            actionLabel: '',
            actionIcon: '',
            action: angular.noop,
          },
          sos: {
            title: 'Emergency Alerts',
            subtitle: 'View the latest SOS signals with fast access to user details and mapped locations.',
            actionLabel: '',
            actionIcon: '',
            action: angular.noop,
          },
          users: {
            title: 'User Registry',
            subtitle: 'Monitor community registrations in a cleaner list that is easier to scan during administration.',
            actionLabel: '',
            actionIcon: '',
            action: angular.noop,
          },
          login: {
            title: 'Admin Login',
            subtitle: '',
            actionLabel: '',
            actionIcon: '',
            action: angular.noop,
          },
        };
        return map[view] || map.dashboard;
      };

      $scope.setPageMeta = function (view) {
        $scope.pageMeta = $scope.pageMetaFor(view);
      };
      $scope.setPageMeta($scope.view);

      $scope.setApiBase = function () {
        if ($scope.apiBase) {
          localStorage.setItem('ws_api_base', $scope.apiBase);
          API_BASE = $scope.apiBase;
        }
      };

      $scope.login = function (event) {
        if (event) {
          event.preventDefault();
        }
        $scope.err = '';
        $http
          .post(API_BASE + '/auth/admin/login', {
            username: $scope.loginForm.username,
            password: $scope.loginForm.password,
          })
          .then(function (res) {
            var t = res.data.data && res.data.data.token;
            if (t) {
              localStorage.setItem('ws_admin_token', t);
              $scope.token = t;
              $scope.view = 'dashboard';
              $scope.setPageMeta('dashboard');
              $scope.loadDashboard();
              $scope.preloadAdminSummary();
            }
          })
          .catch(function (e) {
            $scope.err = (e.data && e.data.message) || 'Login failed';
          });
      };

      $scope.logout = function () {
        localStorage.removeItem('ws_admin_token');
        $scope.token = null;
        $scope.err = '';
        $scope.view = 'login';
        $scope.setPageMeta('login');
      };

      $scope.dashboard = {};
      $scope.loadDashboard = function () {
        $http.get(API_BASE + '/admin/dashboard').then(function (res) {
          $scope.dashboard = res.data.data || {};
        });
      };

      $scope.preloadAdminSummary = function () {
        $scope.loadStations();
        $scope.loadOfficers();
        $scope.loadUsers();
        $scope.loadComplaints();
        $scope.loadSos();
      };

      $scope.loadStations = function () {
        $http.get(API_BASE + '/admin/police-stations').then(function (res) {
          $scope.stations = res.data.data || [];
        });
        $http.get(API_BASE + '/admin/police-stations?deleted=1').then(function (res) {
          $scope.deletedStations = res.data.data || [];
        });
      };

      $scope.stationForm = {};
      $scope.editStation = function (s) {
        $scope.stationForm = s
          ? angular.copy(s)
          : { name: '', address: '', latitude: '', longitude: '', phone: '', email: '' };
        $scope.view = 'stationForm';
        $scope.setPageMeta('stationForm');
      };

      $scope.saveStation = function () {
        var p = {
          name: $scope.stationForm.name,
          address: $scope.stationForm.address,
          latitude: parseFloat($scope.stationForm.latitude),
          longitude: parseFloat($scope.stationForm.longitude),
          phone: $scope.stationForm.phone,
          email: $scope.stationForm.email,
        };
        var req;
        if ($scope.stationForm.id) {
          req = $http.put(API_BASE + '/admin/police-stations/' + $scope.stationForm.id, p);
        } else {
          req = $http.post(API_BASE + '/admin/police-stations', p);
        }
        req
          .then(function () {
            $scope.view = 'stations';
            $scope.setPageMeta('stations');
            $scope.loadStations();
          })
          .catch(function (e) {
            alert((e.data && e.data.message) || 'Save failed');
          });
      };

      $scope.deleteStation = function (id) {
        if (!confirm('Delete this station? It will move to deleted history and linked officers will also be marked deleted.')) return;
        $http.delete(API_BASE + '/admin/police-stations/' + id).then(function () {
          $scope.loadStations();
        });
      };

      $scope.loadOfficers = function () {
        $http.get(API_BASE + '/admin/officers').then(function (res) {
          $scope.officers = res.data.data || [];
        });
        $http.get(API_BASE + '/admin/officers?deleted=1').then(function (res) {
          $scope.deletedOfficers = res.data.data || [];
        });
      };

      $scope.officerForm = {};
      $scope.editOfficer = function (o) {
        $http.get(API_BASE + '/admin/police-stations').then(function (res) {
          $scope.stations = res.data.data || [];
          $scope.officerForm = o
            ? angular.copy(o)
            : {
                station_id: ($scope.stations[0] && $scope.stations[0].id) || '',
                name: '',
                badge_no: '',
                email: '',
                phone: '',
                password: '',
              };
          $scope.view = 'officerForm';
          $scope.setPageMeta('officerForm');
        });
      };

      $scope.saveOfficer = function () {
        var p = {
          station_id: parseInt($scope.officerForm.station_id, 10),
          name: $scope.officerForm.name,
          badge_no: $scope.officerForm.badge_no,
          email: $scope.officerForm.email,
          phone: $scope.officerForm.phone,
        };
        if ($scope.officerForm.password) p.password = $scope.officerForm.password;
        var req;
        if ($scope.officerForm.id) {
          req = $http.put(API_BASE + '/admin/officers/' + $scope.officerForm.id, p);
        } else {
          if (!p.password) {
            alert('Password required for new officer');
            return;
          }
          req = $http.post(API_BASE + '/admin/officers', p);
        }
        req
          .then(function () {
            $scope.view = 'officers';
            $scope.setPageMeta('officers');
            $scope.loadOfficers();
          })
          .catch(function (e) {
            alert((e.data && e.data.message) || 'Save failed');
          });
      };

      $scope.deleteOfficer = function (id) {
        if (!confirm('Delete this officer? It will move to deleted history instead of being removed permanently.')) return;
        $http.delete(API_BASE + '/admin/officers/' + id).then(function () {
          $scope.loadOfficers();
        });
      };

      $scope.complaintFilter = '';
      $scope.selectedComplaint = null;
      $scope.loadComplaints = function () {
        var url = API_BASE + '/admin/complaints';
        if ($scope.complaintFilter) url += '?status=' + encodeURIComponent($scope.complaintFilter);
        $http.get(url).then(function (res) {
          $scope.complaints = res.data.data || [];
          if (!$scope.selectedComplaint && $scope.complaints.length) {
            $scope.selectedComplaint = $scope.complaints[0];
          }
        });
      };

      $scope.selectComplaint = function (complaint) {
        $scope.selectedComplaint = complaint;
      };

      $scope.openComplaintDetail = function (complaint) {
        $scope.selectedComplaint = complaint;
      };

      $scope.closeComplaintDetail = function () {
        $scope.selectedComplaint = null;
      };

      $scope.loadSos = function () {
        $http.get(API_BASE + '/admin/sos-alerts').then(function (res) {
          $scope.sosAlerts = res.data.data || [];
        });
      };

      $scope.loadUsers = function () {
        $http.get(API_BASE + '/admin/users').then(function (res) {
          $scope.users = res.data.data || [];
        });
      };

      $scope.go = function (v) {
        $scope.view = v;
        $scope.setPageMeta(v);
        if (v === 'dashboard') {
          $scope.loadDashboard();
          $scope.preloadAdminSummary();
        }
        if (v === 'stations') $scope.loadStations();
        if (v === 'officers') {
          $scope.loadStations();
          $scope.loadOfficers();
        }
        if (v === 'complaints') $scope.loadComplaints();
        if (v === 'sos') $scope.loadSos();
        if (v === 'users') $scope.loadUsers();
      };

      if ($scope.token) {
        $scope.loadDashboard();
        $scope.preloadAdminSummary();
      }

      $scope.$on('$routeChangeError', function () {
        $scope.logout();
      });
    },
  ]);
})();
