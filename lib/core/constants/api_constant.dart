import 'dart:ui';

import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = "https://paklandhousing.shesoft.com.pk";
  static const String apiKey = 'BRE-crm-mobile-app-2025-secure-key';

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
  static const String getReceiptByReceiptNoUrl = "$baseUrl/api/MobileApi/GetReceiptsPrintByReceiptNo";
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
  static const String sendOtpAuthDevrdUrl = "$baseUrl/api/MobileAPi/DeviceAuth";
  static const String updateProfileUrl = "$baseUrl/api/MobileApi/UpdateUser";
  static const String recentActivityUrl = "$baseUrl/api/MobileApi/GetAllLogsByUser";
  static const String formNoUrl = "$baseUrl/api/MobileApi/FormStatus";
  static const String getFaqsUrl = "$baseUrl/api/MobileApi/GetFAQs";
  static const String getCommunicationPolicyUrl = "$baseUrl/api/MobileAPi/GetCommunicationPolicy";

  static const String addLeadBaseUrl = "https://shecrm.com.pk/crms_updated/api/get-web-form-lead";


  static const String baseUrl2="https://paklandhousing.shesoft.com.pk";

  static const String cmsBase = "$baseUrl2/api/CMS";
  static const String createTicketUrl = "$cmsBase/CreateTicket";
  static const String updateTicketUrl = "$cmsBase/UpdateTicket";
  static const String getTicketUrl = "$cmsBase/GetTicket";
  static const String getAllTicketsUrl = "$cmsBase/GetAllTickets";
  static const String getTicketsByStatusUrl = "$cmsBase/GetTicketsByStatus";
  static const String getTicketsByUserIdUrl = "$cmsBase/GetTicketsByUserId";
  static const String getGetStaffUsersUrl = '${cmsBase}/GetStaffUsers';
  static const String getTicketsByDepartmentUrl = "$cmsBase/GetTicketsByDepartment";
  static const String getDeptsbyBrnCode = "$cmsBase/GetAllDepartmentsByCode";
  static const String updateTicketStatusUrl = "$cmsBase/ChangeTicketStatus";
  static const String deleteTicketUrl = "$cmsBase/DeleteTicket";


  static const String addCommentUrl = "$cmsBase/AddComment";
  static const String getCommentsUrl = "$cmsBase/GetComments";

  static const String uploadMediaUrl = "$cmsBase/UploadMedia";
  static const String getMediaUrl = "$cmsBase/GetMedia";

  static const String createAuditLogUrl = "$cmsBase/CreateAuditLog";
  static const String getAllAuditLogsUrl = "$cmsBase/GetAllAuditLogs";
  static const String getAuditLogsByModuleUrl = "$cmsBase/GetAuditLogsByModule";
  static const String deleteAuditLogUrl = "$cmsBase/DeleteAuditLog";

  static const String submitFeedbackUrl = "$cmsBase/AddFeedback";


  static const String getDepartmentByUID = "$cmsBase/GetDepartmentsByAdmin";
  static const String getDepartment = "$cmsBase/GetAllDepartments";
  static const String getDeptOpration = "$cmsBase/GetDepartmentOperations";

  static const String assignTicketUrl = '${cmsBase}/AssignTicket';
  static const String getUsersByDeptUrl = '${cmsBase}/GetUsersByDept';
  static const String getMyAssignedTicketsUrl = '${cmsBase}/GetAssignedTicketByUserIDAsync';
  static const String getTicketsByAminIdUrl = "$cmsBase/GetTicketsByAdminId";
  static const String getBranchesByUserId = "$cmsBase/GetBranchesByUserId";


  static const String sendSOSNotificationUrl = "$cmsBase/SendSOSNotification";
  static const String updateFCMTokenUrl = "$cmsBase/UpdateFCMToken";
  static const String getSOSTicketUrl = "$cmsBase/GetSOSTicket";
  static const String checkSOSPermissionUrl = "$cmsBase/CheckSOSPermission";
  static const String getAllSOSUsersUrl = "$cmsBase/GetAllSOSUsers";
  static const String getActiveSOSEmergenciesUrl = "$cmsBase/GetActiveSOSEmergencies";
  static const String stopSOSAlarmUrl = "$cmsBase/StopSOSAlarm";
  static const String respondToSOSUrl = "$cmsBase/RespondToSOS";
  static const String testFCMNotificationUrl = "$cmsBase/TestFCMNotification";
  static const String testFCMConnectionUrl = "$cmsBase/TestFCMConnection";




  static String buildImageUrl(String? imagePath) {
    return buildFileUrl(imagePath);
  }
  static String buildFileUrl(String? filePath) {
    if (filePath == null) return '';
    var path = filePath.trim();
    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    path = path.replaceAll('\\', '/');

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl2/';
    return '$base$path';
  }


}
enum TicketSortType {
  newest,
  oldest,
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