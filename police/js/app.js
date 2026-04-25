(function () {
  'use strict';

  var API_BASE = localStorage.getItem('ws_api_base') || 'http://localhost/saftey/backend/api';

  angular.module('wsPolice', []).config([
    '$httpProvider',
    function ($httpProvider) {
      $httpProvider.interceptors.push([
        '$q',
        function ($q) {
          return {
            request: function (config) {
              var t = localStorage.getItem('ws_police_token');
              if (t) {
                config.headers = config.headers || {};
                config.headers.Authorization = 'Bearer ' + t;
              }
              return config;
            },
            responseError: function (rejection) {
              if (rejection.status === 401) {
                localStorage.removeItem('ws_police_token');
              }
              return $q.reject(rejection);
            },
          };
        },
      ]);
    },
  ]);

  angular.module('wsPolice').controller('MainCtrl', [
    '$scope',
    '$http',
    function ($scope, $http) {
      $scope.apiBase = API_BASE;
      $scope.token = localStorage.getItem('ws_police_token');
      $scope.view = $scope.token ? 'complaints' : 'login';
      $scope.loginForm = { email: '', password: '' };
      $scope.err = '';

      $scope.setApiBase = function () {
        if ($scope.apiBase) {
          localStorage.setItem('ws_api_base', $scope.apiBase);
          API_BASE = $scope.apiBase;
        }
      };

      $scope.login = function () {
        $scope.err = '';
        $http
          .post(API_BASE + '/auth/police/login', {
            email: $scope.loginForm.email,
            password: $scope.loginForm.password,
          })
          .then(function (res) {
            var t = res.data.data && res.data.data.token;
            if (t) {
              localStorage.setItem('ws_police_token', t);
              $scope.token = t;
              $scope.view = 'complaints';
              $scope.loadComplaints();
            }
          })
          .catch(function (e) {
            $scope.err = (e.data && e.data.message) || 'Login failed';
          });
      };

      $scope.logout = function () {
        localStorage.removeItem('ws_police_token');
        $scope.token = null;
        $scope.err = '';
        $scope.view = 'login';
      };

      $scope.complaints = [];
      $scope.loadComplaints = function () {
        $http.get(API_BASE + '/police/complaints').then(function (res) {
          $scope.complaints = res.data.data || [];
        });
      };

      $scope.selected = null;
      $scope.openComplaint = function (c) {
        $http.get(API_BASE + '/police/complaints/' + c.complaint_id).then(function (res) {
          $scope.selected = res.data.data;
          $scope.view = 'detail';
        });
      };

      $scope.saveComplaint = function () {
        if (!$scope.selected) return;
        $http
          .patch(API_BASE + '/police/complaints/' + $scope.selected.complaint_id, {
            status: $scope.selected.status,
            police_notes: $scope.selected.police_notes,
          })
          .then(function () {
            $scope.view = 'complaints';
            $scope.loadComplaints();
          })
          .catch(function (e) {
            alert((e.data && e.data.message) || 'Update failed');
          });
      };

      $scope.sosAlerts = [];
      $scope.loadSos = function () {
        $http.get(API_BASE + '/police/sos-alerts').then(function (res) {
          $scope.sosAlerts = res.data.data || [];
        });
      };

      $scope.go = function (v) {
        $scope.view = v;
        if (v === 'complaints') $scope.loadComplaints();
        if (v === 'sos') $scope.loadSos();
      };

      if ($scope.token) {
        $scope.loadComplaints();
      }
    },
  ]);
})();
