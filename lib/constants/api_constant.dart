import 'dart:ui';

import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = "https://paklandhousing.shesoft.com.pk";
  static const String apiKey = 'BRE-crm-mobile-app-2025-secure-key';
  // static const String baseUrl = "https://peakish-mitchel-noncontextually.ngrok-free.dev";

  static const String signUpUrl = "$baseUrl/api/ReportExecl/SendOTP";
  static const String verifyOtpUrl = "$baseUrl/api/ReportExecl/VerifyOTP";
  static const String loginUrl = "$baseUrl/api/ReportExecl/login";
  static const String logoutUrl = "$baseUrl/api/MobileAPi/LogOut";
  static const String getProjectUrl = "$baseUrl/api/MobileAPi/GetProjects";
  static const String getBlockUrl = "$baseUrl/api/MobileApi/GetBlockByProject";
  static const String getPlotSizeUrl = "$baseUrl/api/MobileApi/GetPlotSize";
  static const String addBookingUrl = "$baseUrl/api/MobileApi/Booking";
  static const String getCustomerPortalUrl = "$baseUrl/api/ReportExecl/GetStamentByID";
  static const String getCompanyInfoUrl = "$baseUrl/api/ReportExecl/GetCompanyInfo";
  static const String getBranchUrl = "$baseUrl/api/ReportExecl/GetBranch";
  static const String getStatementUrl = "$baseUrl/api/MobileApi/GetReceiptsByRegistration";
  static const String getReciptUrl = "$baseUrl/api/ReportExecl/GetReceiptByReg_no";
  static const String getAccountStatUrl = "$baseUrl/api/MobileApi/GetAccountStatement";
  static const String getBillUrl = "$baseUrl/api/MobileApi/GetAccountStatement";
  static const String clientBillsUrl = "$baseUrl/api/MobileApi/GetLastThreeBills";

  static const String getPlotNatureUrl = "$baseUrl/api/MobileApi/GetPlotNature";
  static const String getPlotTypeUrl = "$baseUrl/api/MobileApi/GetPlotType";
  static const String getEventsUrl = "$baseUrl/api/ReportExecl/GetCompanyInfo";
  static const String updatePasswordUrl = "$baseUrl/api/ReportExecl/ChangePassword";
  static const String addFeedbackUrl = "$baseUrl/api/ReportExecl/Feedback";
  static const String payNowUrl = "$baseUrl/api/MobileAPi/CheckOut";
  static const String forgotPasswordUrl = "$baseUrl/api/ReportExecl/ForgetPassword";
  static const String updateProfileUrl = "$baseUrl/api/MobileApi/UpdateUser";
  static const String recentActivityUrl = "$baseUrl/api/MobileApi/GetAllLogsByUser";
  static const String formNoUrl = "$baseUrl/api/MobileApi/FormStatus";
  static const String getFaqsUrl = "$baseUrl/api/MobileApi/GetFAQs";

  static const String addLeadBaseUrl = "https://shecrm.com.pk/crms_updated/api/get-web-form-lead";

  // ==================== CMS APIs ====================

  // Tickets APIs
  //static const String baseUrl2="https://cms.shesoft.com.pk";
  static const String baseUrl2="https://paklandhousing.shesoft.com.pk";

  // Tickets APIs
  static const String cmsBase = "$baseUrl2/api/CMS";
  // Ticket endpoints
  static const String createTicketUrl = "$cmsBase/CreateTicket"; // POST
  static const String updateTicketUrl = "$cmsBase/UpdateTicket"; // PUT + /{id}
  static const String getTicketUrl = "$cmsBase/GetTicket"; // GET + /{id}
  static const String getAllTicketsUrl = "$cmsBase/GetAllTickets"; // GET
  static const String getTicketsByStatusUrl = "$cmsBase/GetTicketsByStatus"; // GET + /{status}
  static const String getTicketsByUserIdUrl = "$cmsBase/GetTicketsByUserId"; // GET + /{userId}
  static const String getGetStaffUsersUrl = '${cmsBase}/GetStaffUsers';
  static const String getTicketsByDepartmentUrl = "$cmsBase/GetTicketsByDepartment"; // GET + /{department}
  static const String getDeptsbyBrnCode = "$cmsBase/GetAllDepartmentsByCode";
  static const String updateTicketStatusUrl = "$cmsBase/ChangeTicketStatus"; // PUT
  static const String deleteTicketUrl = "$cmsBase/DeleteTicket"; // DELETE + /{id}/{userId}


  // Comment endpoints
  static const String addCommentUrl = "$cmsBase/AddComment"; // POST
  static const String getCommentsUrl = "$cmsBase/GetComments"; // GET + /{ticketId}

  // Media endpoints
  static const String uploadMediaUrl = "$cmsBase/UploadMedia"; // POST
  static const String getMediaUrl = "$cmsBase/GetMedia"; // GET + /{id}

  // Audit Log endpoints
  static const String createAuditLogUrl = "$cmsBase/CreateAuditLog"; // POST
  static const String getAllAuditLogsUrl = "$cmsBase/GetAllAuditLogs"; // GET
  static const String getAuditLogsByModuleUrl = "$cmsBase/GetAuditLogsByModule"; // GET + /{module}/{moduleItemId}
  static const String deleteAuditLogUrl = "$cmsBase/DeleteAuditLog"; // DELETE + /{id}

  // Feedback endpoints
  static const String submitFeedbackUrl = "$cmsBase/AddFeedback"; // POST
  // Departments and its Oprations


  static const String getDepartmentByUID = "$cmsBase/GetDepartmentsByAdmin";
  static const String getDepartment = "$cmsBase/GetAllDepartments";
  static const String getDeptOpration = "$cmsBase/GetDepartmentOperations";

  // Add these constants to your ApiConstants class
  static const String assignTicketUrl = '${cmsBase}/AssignTicket';
  static const String getUsersByDeptUrl = '${cmsBase}/GetUsersByDept';
  static const String getMyAssignedTicketsUrl = '${cmsBase}/GetAssignedTicketByUserIDAsync';
  static const String getTicketsByAminIdUrl = "$cmsBase/GetTicketsByAdminId";
  static const String getBranchesByUserId = "$cmsBase/GetBranchesByUserId"; // GET + {UserId}

// ==================== 🚨 SOS APIs ====================

  static const String sendSOSNotificationUrl = "$cmsBase/SendSOSNotification"; // POST
  static const String updateFCMTokenUrl = "$cmsBase/UpdateFCMToken"; // POST
  static const String getSOSTicketUrl = "$cmsBase/GetSOSTicket"; // GET + /{ticketId}
  static const String checkSOSPermissionUrl = "$cmsBase/CheckSOSPermission"; // GET + /{userId}
  static const String getAllSOSUsersUrl = "$cmsBase/GetAllSOSUsers"; // GET
  static const String getActiveSOSEmergenciesUrl = "$cmsBase/GetActiveSOSEmergencies"; // GET
  static const String stopSOSAlarmUrl = "$cmsBase/StopSOSAlarm"; // POST
  static const String respondToSOSUrl = "$cmsBase/RespondToSOS"; // POST
  static const String testFCMNotificationUrl = "$cmsBase/TestFCMNotification"; // POST
  static const String testFCMConnectionUrl = "$cmsBase/TestFCMConnection"; // GET




  static String buildImageUrl(String? imagePath) {
    return buildFileUrl(imagePath);
  }
  static String buildFileUrl(String? filePath) {
    if (filePath == null) return '';
    var path = filePath.trim();
    if (path.isEmpty) return '';

    // Already absolute URL - return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Normalize path separators
    path = path.replaceAll('\\', '/');

    // Remove leading slash if present (to avoid double slashes)
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    // Build the URL - simply append the path to your server base
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl2/';
    return '$base$path';
  }


}
enum TicketSortType {
  newest,
  oldest,
  // priorityHigh,
  // priorityLow,
}
TextStyle dropdownItemsText = TextStyle(
  fontSize: 12,
  color: Colors.black87,
  fontWeight: FontWeight.w500,
);

TextStyle dropdownLables = TextStyle(
  fontSize: 14,
  color: Colors.black,
  fontWeight: FontWeight.bold,
);