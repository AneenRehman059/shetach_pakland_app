// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:get/get.dart';
// import 'controllers/get_account_statement_controller.dart';
// import 'models/get_statement_model.dart';
//
// class PDFStatementService {
//   static Future<Uint8List> generateStatementPDF({
//     required AccountStatementController controller,
//     required String registrationNo,
//     required String clientName,
//   }) async {
//     final pdf = pw.Document();
//     final statements = controller.statementList;
//     final imageData = await rootBundle.load('assets/images/logo.png');
//     final image = pw.MemoryImage(imageData.buffer.asUint8List());
//
//     final group1Statements = statements.where((s) => s.grp == '1').toList();
//     final group3Statements = statements.where((s) => s.grp == '3').toList();
//
//     double totalDue(List<Statement> list) => list.fold(0, (sum, s) => sum + (s.dueAmt ?? 0));
//     double totalPaid(List<Statement> list) => list.fold(0, (sum, s) => sum + (s.amtReceived ?? 0));
//     double totalOs(List<Statement> list) => list.fold(0, (sum, s) => sum + (s.osAmt ?? 0));
//     double totalRebat(List<Statement> list) => list.fold(0, (sum, s) => sum + (s.rebatAmt ?? 0));
//
//     final group1Due = totalDue(group1Statements);
//     final group1Paid = totalPaid(group1Statements);
//     final group1Os = totalOs(group1Statements);
//     final group1Rebat = totalRebat(group1Statements);
//
//     final group3Due = totalDue(group3Statements);
//     final group3Paid = totalPaid(group3Statements);
//     final group3Os = totalOs(group3Statements);
//     final group3Rebat = totalRebat(group3Statements);
//
//     final grandDue = group1Due + group3Due;
//     final grandPaid = group1Paid + group3Paid;
//     final grandOs = group1Os + group3Os;
//     final grandRebat = group1Rebat + group3Rebat;
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) => [
//           _buildHeader(image),
//           _buildClientInfo(registrationNo, clientName),
//           pw.SizedBox(height: 15),
//           ..._buildGroup1Section(group1Statements, group1Due, group1Paid, group1Rebat, group1Os),
//           ..._buildGroup3Section(group3Statements, group3Due, group3Paid, group3Rebat, group3Os),
//           _buildGrandTotalSection(grandDue, grandPaid, grandRebat, grandOs),
//           _buildFooter(),
//         ],
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   static pw.Widget _buildHeader(pw.ImageProvider image) {
//     return pw.Center(
//       child: pw.Column(
//         children: [
//           pw.Container(
//             width: 80,
//             height: 80,
//             child: pw.Image(image, fit: pw.BoxFit.contain),
//           ),
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'Account Statement',
//             style: pw.TextStyle(
//               fontSize: 20,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.blue700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _buildClientInfo(String registrationNo, String clientName) {
//     return pw.Container(
//       padding: pw.EdgeInsets.all(10),
//       child: pw.Row(
//
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.RichText(
//             text: pw.TextSpan(
//               children: [
//                 pw.TextSpan(
//                   text: 'Registration# ',
//                   style: pw.TextStyle(
//                     color: PdfColors.black,
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.TextSpan(
//                   text: registrationNo,
//                   style: pw.TextStyle(
//                     color: PdfColors.blue700,
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 5),
//           pw.RichText(
//             text: pw.TextSpan(
//               children: [
//                 pw.TextSpan(
//                   text: 'Name: ',
//                   style: pw.TextStyle(
//                     color: PdfColors.black,
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.TextSpan(
//                   text: '($clientName)',
//                   style: pw.TextStyle(
//                     color: PdfColors.blue700,
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static List<pw.Widget> _buildGroup1Section(
//       List<Statement> statements,
//       double due,
//       double paid,
//       double rebat,
//       double os,
//       ) {
//     if (statements.isEmpty) return [pw.SizedBox()];
//
//     return [
//       _buildTable(statements),
//       _buildSubTotalRow('Sub Total', due, paid, rebat, os),
//       pw.SizedBox(height: 15),
//     ];
//   }
//
//   static List<pw.Widget> _buildGroup3Section(
//       List<Statement> statements,
//       double due,
//       double paid,
//       double rebat,
//       double os,
//       ) {
//     if (statements.isEmpty) return [pw.SizedBox()];
//
//     return [
//       pw.Center(
//         child: pw.Text(
//           'Extra Charges',
//           style: pw.TextStyle(
//             fontSize: 16,
//             fontWeight: pw.FontWeight.bold,
//             color: PdfColors.blue700,
//           ),
//         ),
//       ),
//       pw.SizedBox(height: 10),
//       _buildTable(statements),
//       _buildSubTotalRow('Sub Total', due, paid, rebat, os),
//       pw.SizedBox(height: 15),
//     ];
//   }
//
//   static pw.Widget _buildTable(List<Statement> statements) {
//     return pw.TableHelper.fromTextArray(
//       context: null,
//       border: pw.TableBorder.all(color: PdfColors.black, width: 1),
//       headerStyle: pw.TextStyle(
//         fontWeight: pw.FontWeight.bold,
//         fontSize: 10,
//         color: PdfColors.white,
//       ),
//       headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
//       cellStyle: pw.TextStyle(fontSize: 9),
//       cellAlignment: pw.Alignment.center,
//       columnWidths: {
//         0: pw.FlexColumnWidth(1.5), // Payment Type (slightly reduced)
//         1: pw.FlexColumnWidth(0.9), // Inst. No. (slightly reduced)
//         2: pw.FlexColumnWidth(1.6), // Inst. Date (slightly reduced)
//         3: pw.FlexColumnWidth(1.3), // Due Amt (increased from 1.0 to 1.3)
//         4: pw.FlexColumnWidth(1.3), // Paid Amt (increased from 1.0 to 1.3)
//         5: pw.FlexColumnWidth(1.0), // Rebat Amt (kept same)
//         6: pw.FlexColumnWidth(1.3), // OS Amt (increased from 1.0 to 1.3)
//       },
//       headers: [
//         'Payment Type',
//         'Inst. No.',
//         'Inst. Date',
//         'Due Amt',
//         'Paid Amt',
//         'Rebat Amt',
//         'OS Amt'
//       ],
//       data: statements.map((s) => [
//         s.paymentType ?? '',
//         '${s.installmentNo ?? ''}',
//         _formatDate(s.dates),
//         _formatCurrency(s.dueAmt),
//         _formatCurrency(s.amtReceived),
//         _formatCurrency(s.rebatAmt),
//         _formatCurrency(s.osAmt),
//       ]).toList(),
//     );
//   }
//
//   static pw.Widget _buildSubTotalRow(String title, double due, double paid, double rebat, double os) {
//     return pw.Table(
//       border: pw.TableBorder.all(color: PdfColors.black, width: 1),
//       columnWidths: {
//         0: pw.FlexColumnWidth(1.5), // Empty for Payment Type
//         1: pw.FlexColumnWidth(0.9), // Empty for Inst. No.
//         2: pw.FlexColumnWidth(1.6), // Title column
//         3: pw.FlexColumnWidth(1.3), // Due Amt (increased)
//         4: pw.FlexColumnWidth(1.3), // Paid Amt (increased)
//         5: pw.FlexColumnWidth(1.0), // Rebat Amt (same)
//         6: pw.FlexColumnWidth(1.3), // OS Amt (increased)
//       },
//       children: [
//         pw.TableRow(
//           children: [
//             pw.Container(), // Empty for Payment Type
//             pw.Container(), // Empty for Inst. No.
//             pw.Container(
//               padding: pw.EdgeInsets.all(6),
//               child: pw.Center(
//                 child: pw.Text(
//                   title,
//                   style: pw.TextStyle(
//                     fontWeight: pw.FontWeight.bold,
//                     fontSize: 10,
//                     color: PdfColors.orange700,
//                   ),
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(6),
//               child: pw.Text(
//                 _formatCurrency(due),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 10,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(6),
//               child: pw.Text(
//                 _formatCurrency(paid),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 10,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(6),
//               child: pw.Text(
//                 _formatCurrency(rebat),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 10,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(6),
//               child: pw.Text(
//                 _formatCurrency(os),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 10,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   static pw.Widget _buildGrandTotalSection(double due, double paid, double rebat, double os) {
//     return pw.Table(
//       border: pw.TableBorder.all(color: PdfColors.black, width: 1),
//       columnWidths: {
//         0: pw.FlexColumnWidth(1.5), // Empty for Payment Type
//         1: pw.FlexColumnWidth(0.9), // Empty for Inst. No.
//         2: pw.FlexColumnWidth(1.6), // Title column
//         3: pw.FlexColumnWidth(1.3), // Due Amt (increased)
//         4: pw.FlexColumnWidth(1.3), // Paid Amt (increased)
//         5: pw.FlexColumnWidth(1.0), // Rebat Amt (same)
//         6: pw.FlexColumnWidth(1.3), // OS Amt (increased)
//       },
//       children: [
//         pw.TableRow(
//           decoration: pw.BoxDecoration(
//             color: PdfColors.grey100,
//           ),
//           children: [
//             pw.Container(), // Empty for Payment Type
//             pw.Container(), // Empty for Inst. No.
//             pw.Container(
//               padding: pw.EdgeInsets.all(8),
//               child: pw.Center(
//                 child: pw.Text(
//                   'Grand Total',
//                   style: pw.TextStyle(
//                     fontWeight: pw.FontWeight.bold,
//                     fontSize: 11,
//                     color: PdfColors.orange700,
//                   ),
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(8),
//               child: pw.Text(
//                 _formatCurrency(due),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 11,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(8),
//               child: pw.Text(
//                 _formatCurrency(paid),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 11,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(8),
//               child: pw.Text(
//                 _formatCurrency(rebat),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 11,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//             pw.Container(
//               padding: pw.EdgeInsets.all(8),
//               child: pw.Text(
//                 _formatCurrency(os),
//                 textAlign: pw.TextAlign.right,
//                 style: pw.TextStyle(
//                   fontWeight: pw.FontWeight.bold,
//                   fontSize: 11,
//                   color: PdfColors.orange700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   static pw.Widget _buildFooter() {
//     return pw.Container(
//       margin: pw.EdgeInsets.only(top: 20),
//       child: pw.Center(
//         child: pw.Text(
//           'Generated on ${_formatDate(DateTime.now())}',
//           style: pw.TextStyle(
//             fontSize: 10,
//             color: PdfColors.grey600,
//           ),
//         ),
//       ),
//     );
//   }
//
//   static String _formatDate(DateTime? date) {
//     if (date == null) return '';
//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }
//
//   static String _formatCurrency(double? amount) {
//     if (amount == null) return '0';
//     return amount.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]},',
//     );
//   }
// }