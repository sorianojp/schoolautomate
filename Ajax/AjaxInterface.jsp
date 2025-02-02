<%
//System.out.println("User index in session : "+request.getSession(false).getAttribute("userIndex"));
//HttpSession httpS = request.getSession(false);
//System.out.println("User ID : "+httpS.getAttribute("userID"));
//System.out.println("httpS : "+httpS.getCreationTime());
//System.out.println(" end of ajax checknig session object ");
%>
<%@ page language="java" import="utility.*"%>
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1

//System.out.println("IF committed 2: "+response.isCommitted());
WebInterface WI     = new WebInterface(request);
String strMethodRef = request.getParameter("methodRef");
if(strMethodRef == null) {
	response.getWriter().print("Error Msg : Invalid Method Call");
	return;
}
//make sure only specific Ajax called by student.
boolean bolIsStudent = false;
String strTemp       = null;

strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strTemp == null) {
	strTemp = "";
	//response.getWriter().print("Error Msg : You are already logged out");
	//return;
}
else if(strTemp.equals("4") && !strMethodRef.equals("211")) {///// list here all student calls..
	bolIsStudent = true;//not used yet.. 
	
	if(strMethodRef.equals("123")) {//fatima plan -- check if called by same student.
		strTemp = (String)request.getSession(false).getAttribute("userIndex");
		if(!strTemp.equals(WI.fillTextValue("stud_ref"))) {
			response.getWriter().print("Error Msg : Not Authorized.");
			return;
		}
	}
	else if(!strMethodRef.equals("213")) {
		response.getWriter().print("Error Msg : Not Authorized");
		return;
	}

}





String strRetResult = null; String strSQLQuery = null;
AjaxInterface AI    = new AjaxInterface();
DBOperation dbOP    = null;
String strErrMsg    = null;
eDTR.eDTRAjax dtrAjax = new eDTR.eDTRAjax();

hr.HRAjax hrAjax = new hr.HRAjax();

Accounting.billing.BillingTsuneishi billTsu = new Accounting.billing.BillingTsuneishi();
Accounting.Budget budget    = new Accounting.Budget();
Accounting.SalesPayment sp  = new Accounting.SalesPayment();
Accounting.SOAManagement sm = new Accounting.SOAManagement();
Accounting.JvCD jvCD        = new Accounting.JvCD();

Accounting.TsuneishiDC tsuDC = new Accounting.TsuneishiDC();

visitor.VisitorInfo visitor = new visitor.VisitorInfo();
projMgmt.GTIProject proj = new projMgmt.GTIProject();
projMgmt.GTIProjectTodo todo = new projMgmt.GTIProjectTodo();


kiosk.EmployeeKiosk empKiosk = new kiosk.EmployeeKiosk();
payroll.PRAjaxInterface prAI = new payroll.PRAjaxInterface();

enrollment.FAStudMinReqDP minDP = new enrollment.FAStudMinReqDP(dbOP);

docTracking.DocumentType docType = new docTracking.DocumentType();
utility.GenericAjax ga = new utility.GenericAjax();

Accounting.invoice.CommercialInvoiceMgmt cim = new Accounting.invoice.CommercialInvoiceMgmt();


bookstore.BookOrders bo = new bookstore.BookOrders();
//aaron
enrollment.ScaledScoreConversion scaledConv = new enrollment.ScaledScoreConversion();
locker.LockerOperations lockers = new locker.LockerOperations();
osaGuidance.StudentPersonalDataCIT SPDCit = new osaGuidance.StudentPersonalDataCIT();

enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();

hmsOperation.RestPOS hmsPOS= new hmsOperation.RestPOS();
hmsOperation.RSFoodRequest rsFood = new hmsOperation.RSFoodRequest();
enrollment.DocRequestTracking docReq = new enrollment.DocRequestTracking();
enrollment.SubjectSection SS = new enrollment.SubjectSection();
			
enrollment.FAFeePost faPost = new enrollment.FAFeePost();
boolean bolIsLoginReqd = true;

hr.HREvaluationSheetExtn ESExtn = new hr.HREvaluationSheetExtn();

try {
	dbOP = new DBOperation();

	//for kiosk application;
	kiosk.Student kioskStudent = new kiosk.Student();
		//for personnel asset management operations
	hr.PersonnelAssetManagement pam = new hr.PersonnelAssetManagement();
	//for system help file operations
	utility.SystemHelpFile shf = new utility.SystemHelpFile();
	// for inventory - starts at 1500
	//inventory.invAjaxInterface invAI = new inventory.invAjaxInterface();
	
	//for basic education
	basicEdu.BasicGE basicGE = new basicEdu.BasicGE();

	int iMethodRef = Integer.parseInt(strMethodRef);
	switch(iMethodRef) {
		case 1:
			strRetResult = AI.quickSearch(dbOP, request);
			break;
		case 2:
			strRetResult = AI.quickSearchName(dbOP, request);
			break;
		case 3:
			strRetResult = basicGE.ajaxSearchSection(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+basicGE.getErrMsg();
			break;
		case 4:
			strRetResult = basicGE.ajaxSearchSubjects(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+basicGE.getErrMsg();
			break;
		case 5:
			strRetResult = basicGE.ajaxUpdateConductRate(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg: "+basicGE.getErrMsg();
			break;
		case 6:
			strRetResult = basicGE.ajaxUpdateCharacterRate(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg: "+basicGE.getErrMsg();
			break;
		case 7:
		 	strRetResult = basicGE.ajaxUpdateSubjectAttendance(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg: "+basicGE.getErrMsg();
			break;
		case 8:
			strRetResult = basicGE.ajaxSearchAdvisees(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+basicGE.getErrMsg();
			break;
		
		case 98://called for misc or tuition fee modification.		
			strRetResult = faPost.ajaxUpdatePostCharge(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+faPost.getErrMsg();
			break;
		case 99://called for misc or tuition fee modification.
			strRetResult = RFA.ajaxUpdateDistinctMiscFee(dbOP, request);
			break;
		case 100://called for misc or tuition fee modification.
			strRetResult = RFA.ajaxUpdateSubjectFeeWithCatg(dbOP, request);
			break;
		case 101://called for misc or tuition fee modification.
			strRetResult = AI.modifyTuitionMiscFee(dbOP, request);
			break;
		case 102://called for to get Or information.
			strRetResult = new enrollment.FAPayment().ajaxGetORInfo(dbOP, request);
			break;
		case 103:
			if(new OLExam.OLEQuestionnair().editQN(dbOP, request))
				strRetResult = "success";
			else
				strRetResult = "";
			break;
		case 104: //load major list..
			strRetResult = AI.loadMajor(dbOP, request);
			//System.out.println(strRetResult);
			break;
		//case 105: //load major list..
		//	strRetResult = AI.loadMajor(dbOP, request);
			//System.out.println(strRetResult);
		//	break;

		/********************* all about chat ***************************************/
		case 105: //Send and receive chat message.
			strRetResult = AI.chatMessageSendReceive(dbOP, request);
			request.getSession(false).setAttribute("chat_msg",strRetResult);
			break;
		case 106: //Chat Archive - when chat user is clicked.
			strRetResult = AI.chatMessageShowDate(dbOP, request);
			break;
		case 107: //Chat Archive - when chat date is clicked for a user.
			strRetResult = AI.chatMessageShowMessage(dbOP, request);
			break;
		case 108: //Search Chat user - in chat_main.jsp
			strRetResult = AI.searchUser(dbOP, request);
			break;
		case 109: //removes the chat user reference from session.
			strRetResult = WI.fillTextValue("userIndex");
			java.util.Vector vChatUser = (java.util.Vector)request.getSession(false).getAttribute("vChatUser");
			if(vChatUser != null && vChatUser.size() > 0)
				vChatUser.removeElement(strRetResult);
			request.getSession(false).setAttribute("vChatUser",vChatUser);
			if(vChatUser.size() == 0) {
				strRetResult = "update user_table set is_active_ = 0 where user_index = "+
									(String)request.getSession(false).getAttribute("userIndex");
				dbOP.executeUpdateWithTrans(strRetResult, null, null, false);
			}
			strRetResult = "Error Msg : Chat window closing.";
			break;
		case 110: //chat pop message
			if(request.getSession(false).getAttribute("userIndex") == null) {//if user not logged in , return.
				strRetResult = "";
				break;
			}
			long lTimeNow = new java.util.Date().getTime();
			String strLastCalled = (String)request.getSession(false).getAttribute("chatMsgAttrived");
			if(strLastCalled == null) {
				strLastCalled = "0";
				request.getSession(false).setAttribute("chatMsgAttrived", Long.toString(lTimeNow));
				strRetResult = "";
				break;
			}
			long lLastAccessed = Long.parseLong(strLastCalled);
			lLastAccessed = lTimeNow - lLastAccessed;
			//System.out.println(lLastAccessed);
			if(lLastAccessed < 15000l) {//	if already called less than 15secs, i must return here.
				strRetResult = "";
				break;
			}
			request.getSession(false).setAttribute("chatMsgAttrived", Long.toString(lTimeNow));
			strRetResult = AI.chatPopMessage(dbOP, request);
			request.getSession(false).setAttribute("chat_msg",strRetResult);
			//System.out.println(strRetResult);
			break;
		case 111: //load Exam schedule Code.
			strRetResult = AI.loadPlacementExamCode(dbOP, request);
			break;
		case 112: //load dept
			//System.out.println("I am here.");
			strRetResult = AI.loadDept(dbOP, request);
			break;
		case 113: //Called load highschool year level when education level is changed.
			strRetResult = AI.loadGradeYrLevel(dbOP, request);
			break;
		case 114: //call this ajax in assessed_fees_basic.jsp to update the required d/p of student..
			if(WI.fillTextValue("stud_id").length() > 0) {
				strRetResult = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
				if(strRetResult == null) {
					strErrMsg = "Student ID not found.";
					break;
				}
				break;
			}

			if(minDP.updateRequiredDPPerStud(dbOP, request))
				strRetResult = "success";
			else
				strRetResult = minDP.getErrMsg();
			break;
		case 115: //call this to update highschool full payment discount..
				strRetResult = new enrollment.FAFeeMaintenanceVairable().adjaxUpdateFD(dbOP, request);
			break;
		case 116: //call this to update highschool full payment discount..
				strRetResult = new enrollment.FAStudentLedger().updateSemestralRemark(dbOP, request);
				if(strRetResult == null)
					strRetResult = "success";
				else
					strRetResult = "Error Msg : "+strRetResult;

			break;
		case 117: //call this to update fields of issuance -- for AUF /
				strRetResult = new inventory.InventoryMaintenance().ajaxUpdateIssuanceInfo(dbOP, request);
				//if(strRetResult == null)
				//	strRetResult = "suecess";
				//else
				//	strRetResult = "Error Msg : "+strRetResult;
		case 118: //call this to update line number printed for AUF
				strRetResult = AI.updateAufLedgLinePrint(dbOP, request);
			break;
		case 119: //call this to update unclaimed PN of AUF.. 
				strRetResult = "update FA_STUD_PROMISORY_NOTE set AUF_UNCLAIMED_PERMIT = "+ConversionTable.replaceString(WI.fillTextValue("new_val"), ",","")+
								" where pn_index = "+WI.fillTextValue("pn_ref");
				if(dbOP.executeUpdateWithTrans(strRetResult, null, null, false) == -1)
					strRetResult = "Failed to Update.";
				else	
					strRetResult = "success";
				
			break;
		case 120: //call this for wnu - updating form 9 - 
				strRetResult = WI.fillTextValue("field_ref");
				if(strRetResult.equals("1"))
					strRetResult = "WNU_EL_NO";
				else if(strRetResult.equals("2"))	
					strRetResult = "WNU_CON_ADDR_REL";
				else if(strRetResult.equals("3"))
					strRetResult = "WNU_REMOVE_ROTC";
				else if(strRetResult.equals("4"))
					strRetResult = "WNU_REMOVE_MAJOR_TOR";
				else if(strRetResult.equals("5"))
					strRetResult = "WNU_REMOVE_MAJOR_FORM9";
					
				strRetResult = "update ENTRANCE_DATA set "+strRetResult+" = "+WI.getInsertValueForDB(WI.fillTextValue("new_val"), true, null) + 
								" where STUD_INDEX = "+WI.fillTextValue("stud_ref");
				if(dbOP.executeUpdateWithTrans(strRetResult, null, null, false) < 1)
					strRetResult = "Failed to Update.";
				else	
					strRetResult = "successfully saved";
				
			break;
		case 121: //call this for wnu - updating form 9 required number of units.- 				
				strRetResult = WI.fillTextValue("student_");//System.out.println("I am here.");
				strRetResult = dbOP.mapUIDToUIndex(strRetResult);//System.out.println(strRetResult);
				if(strRetResult != null) {
					//check if existing, if not, i have to create
					if(dbOP.getResultOfAQuery("select stud_index from FORM9_REQUIRED_UNIT where stud_index = "+strRetResult, 0) == null)//create.
						strRetResult = "insert into FORM9_REQUIRED_UNIT (stud_index, group"+WI.fillTextValue("group")+") values ("+strRetResult+", "+WI.fillTextValue("new_val")+")";
					else
						strRetResult = "update FORM9_REQUIRED_UNIT set group"+WI.fillTextValue("group")+" = "+WI.fillTextValue("new_val")+" where stud_index="+strRetResult;
					
					if(dbOP.executeUpdateWithTrans(strRetResult, null, null, false) < 1)
						strRetResult = "Failed";
					else	
						strRetResult = WI.fillTextValue("new_val");
				}
				else
					strRetResult = "Error Msg : Wrong Student ID.";
			break;
		case 122: //
				strRetResult = RFA.ajaxUpdateAdmSlipNo(dbOP, request);
				if(strRetResult == null)
					strRetResult = "Error Msg :"+RFA.getErrMsg();
				//System.out.println();
			break;
		case 123: //
				strRetResult = minDP.updateInstallmentPlan(dbOP, request);
				if(strRetResult == null)
					strRetResult = "Error Msg :"+minDP.getErrMsg();
				//System.out.println();
			break;

		case 124: //toggle force close.. 
				String strSchCode = (String)request.getSession(false).getAttribute("school_code");
				if(strSchCode == null)
					strSchCode = "";
					
				strTemp = WI.fillTextValue("sub_sec_ref");
				String strUpdateField = null;
				if(WI.fillTextValue("update_dc").length() > 0)
					strUpdateField = "donot_check_conflict";
				else
					strUpdateField = "is_force_closed";
				
				strSQLQuery = "select "+strUpdateField+" from e_sub_section where sub_sec_index = "+strTemp;
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null) {
					if(strSQLQuery.equals("0"))
						strTemp = "1";
					else	
						strTemp = "0";
					strSQLQuery = "update e_sub_section set "+strUpdateField+" = "+strTemp+" where sub_sec_index = "+
						WI.fillTextValue("sub_sec_ref");
					if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1)	
						strRetResult = "Error Msg: Failed to Update";
					else {
						if(strTemp.equals("1")) {
							if(WI.fillTextValue("update_dc").length() > 0)
								strRetResult = "Donot Check";
							else {
								if(strSchCode.startsWith("SWU"))
									strRetResult = "For Dissolve";
								else
									strRetResult = "Force Closed";
							}
						}
						else {
							if(WI.fillTextValue("update_dc").length() > 0)
								strRetResult = "Check Conflict";
							else	
								strRetResult = "&nbsp;";
						}
					}
				}
			break;
		case 125: //
				strSQLQuery = WI.fillTextValue("capacity");
				if(strSQLQuery.length() > 0) {
					strSQLQuery = "update e_sub_section set capacity = "+strSQLQuery +" where sub_sec_index = "+WI.fillTextValue("sub_sec_ref");
					if(dbOP.executeUpdateWithTrans(strSQLQuery, (String)request.getSession(false).getAttribute("login_log_index"), "E_SUB_SECTION", true) == -1)	
						strRetResult = "Error Msg: Failed to Update";
					else {
						strSQLQuery = "update e_sub_section set capacity = "+WI.fillTextValue("capacity") +" where MIX_SEC_REF_INDEX = "+WI.fillTextValue("sub_sec_ref");
						dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
						strRetResult = WI.fillTextValue("capacity");
						
						
						//update now all merged section.
					}
				}
			break;

		case 126: //called to update refund type index of a refund.. page: posted_to_ledger_summary.jsp
				strRetResult = new enrollment.FAExternalPay(request).ajaxUpdateRefundType(dbOP, request);
				if(strRetResult == null)
					strRetResult = "Failed to Update.";
				//System.out.println(strRetResult);
			break;
		case 127: //called to get Dept/college head.
				if(WI.fillTextValue("col_ref").length()> 0) {
					strSQLQuery = "select dean_name from college where c_index = "+WI.fillTextValue("col_ref");
					strRetResult = dbOP.getResultOfAQuery(strSQLQuery, 0) ;
				}
				if(WI.fillTextValue("dep_ref").length()> 0) {
					strSQLQuery = "select dh_name from department where d_index = "+WI.fillTextValue("dep_ref");
					strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0) ;
					if(strSQLQuery != null)
						strRetResult = strSQLQuery;
				}
				if(strRetResult== null || strRetResult.length() == 0)
					strRetResult = "Error Msg :Department Head name is not pre-set.";
				
			break;
		case 128: //search section per offered by college/dept.
			strRetResult = SS.ajaxSearchSection(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+SS.getErrMsg();
			break;

		case 129: //search subject == creates subject drop down list used in class_offered_stat_open.jsp
			bolIsLoginReqd = false;
			
			String strSelectName = WI.fillTextValue("sel_name");
			String strSubjectEntered = WI.fillTextValue("subject");
			String strOnChangeMethod = WI.fillTextValue("onchange");
			if(strOnChangeMethod.length() > 0) 
				strOnChangeMethod = " onChange='"+strOnChangeMethod+"()'";
			
			strSQLQuery = utility.ConversionTable.replaceString(strSubjectEntered, "'", "''");
			strSQLQuery = "select sub_index, sub_code, sub_name from subject "+
							" where (sub_code like '%"+strSQLQuery+"%' or sub_name like '%"+strSQLQuery+
							"%') and is_del = 0";
			if(WI.fillTextValue("offering_syf").length() > 0) 
				strSQLQuery +=" and exists (select sub_sec_index from e_sub_section where subject.sub_index = "+
				"e_sub_section.sub_index and is_valid = 1 and offering_sy_from = "+
				WI.fillTextValue("offering_syf")+" and offering_sem = "+WI.fillTextValue("offering_sem")+" and IS_CHILD_OFFERING = 0 and is_lec = 0)";
			strSQLQuery += " order by sub_code";
			
			StringBuffer strBuf = new StringBuffer();
        	strBuf.append("<select name='"+strSelectName+"' style='font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;'");
			strBuf.append(strOnChangeMethod);
			strBuf.append(">");
			//System.out.println("Printing: 2");System.out.println(strSQLQuery);System.out.println(strBuf);
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()) {
				strBuf.append("<option value='");
				strBuf.append(rs.getString(1));
				strBuf.append("'>"+rs.getString(2)+"&nbsp;&nbsp;&nbsp;("+rs.getString(3)+")</option>");
			}
			rs.close();
			strBuf.append("</select>");
			strRetResult = strBuf.toString();
			//System.out.println("Printing: "+strRetResult);
			break;

		case 150://all arithmatic operations are called here.. called for sum.
			java.util.Vector vTemp = CommonUtil.convertCSVToVector(request.getParameter("input"), "_", true);
			double dRetResult = 0d;
			while(vTemp.size() > 0)
				dRetResult += Double.parseDouble(ConversionTable.replaceString((String)vTemp.remove(0),",",""));

			if(request.getParameter("format") != null)
				strRetResult = CommonUtil.formatFloat(dRetResult, true);
			else
				 strRetResult = ConversionTable.replaceString(CommonUtil.formatFloat(dRetResult, true), ",","");

			break;
		case 151: //inventory log, update quantity :: to answers donbosco rfc..
			inventory.InventoryLog invLog = new inventory.InventoryLog();
			strRetResult = invLog.ajaxUpdateInventoryEntryLogQty(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+invLog.getErrMsg();
			break;
		case 152: //called to get the change in teller. - request of CSA.. they want to see the change on screen.. 
			//param : amt_paid, amt_tendered
			try {
				double dChange     = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("amt_tendered"),",","")) - Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("amt_paid"),",",""));
				//if(dChange < 0)
				//	dChange = 0;
				if(WI.fillTextValue("amt_tendered").length() == 0) 
					dChange = 0d;
				strRetResult = CommonUtil.formatFloat(dChange, true);				
			}
			catch(Exception e) {
				strRetResult = "0.00";
			}
			break;
		case 153: //called to format Amount. 
			//param : amt_paid, show if less than 1,000
			try {
				double dChange     = Double.parseDouble(ConversionTable.replaceString(WI.fillTextValue("amt_"),",",""));
				strRetResult = "Formatted: "+CommonUtil.formatFloat(dChange, true);				
			}
			catch(Exception e) {
				strRetResult = "0.00";
			}
			break;
		case 154: //called to format Amount in the text box.. 
			//param : amt_paid, show if less than 1,000
			try {
				strTemp = WI.fillTextValue("amt_");
				if(strTemp.indexOf(".") > -1)
					strRetResult = strTemp;
				else {
					strTemp = strTemp = ConversionTable.replaceString(strTemp,",","");
					if(strTemp.length() < 3) 
						strRetResult = strTemp;
					else {
						double dChange     = Double.parseDouble(strTemp);
						strRetResult = CommonUtil.formatFloat(dChange, false);	
					}
				}
			}
			catch(Exception e) {
				strRetResult = "0";
			}
			break;
		/********************* end of all about chat ********************************/
		/********************* All about SMS ****************************************/
		case 190:
			strRetResult = AI.ajaxInterfaceGetSMSToProcessStat(dbOP);
			break;
		/********************* end of SMS *******************************************/

		case 201://called to update Serial number of NSTP.
			strRetResult = new enrollment.ReportRegistrar().updateNSTPSLNo(dbOP, request.getParameter("user_index"),
				request.getParameter("sl_no"), request.getParameter("spl"));
			break;
		case 202: //called in authentication page to assign user to be exclusive for basic education.
			enrollment.Authentication auth = new enrollment.Authentication();
			strRetResult = auth.ajaxToggleBasicUser(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+auth.getErrMsg();
			break;
		case 203: //Called to
			student.ChangeCriticalInfo CI = new student.ChangeCriticalInfo();
			strRetResult = CI.ajaxUpdateRegStatTempStud(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+CI.getErrMsg();
			break;
		case 204: //Called to update Ched form F updateOfferingCount
			chedReport.FNew fNew = new chedReport.FNew();
			strRetResult = fNew.ajaxUpdate(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+fNew.getErrMsg();
			break;
		case 205: //Called to update the offering count of e_sub_section. modifyEndOfTORRemark
			strRetResult = SS.updateOfferingCount(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+SS.getErrMsg();
			break;
		case 206: //Called to update the end of transcript remark for WNU.. they print this remark after printing end of tor remark..
			strRetResult = AI.modifyEndOfTORRemark(dbOP, request);
			//System.out.println(WI.fillTextValue("endof_tor_remark"));
			if(strRetResult == null)
				strRetResult = "Error Msg : "+AI.getErrMsg();
			break;
		case 207: //Called to update remark in wnu final grade sheet printing..
			strSQLQuery = "update g_sheet_final set remark_index = "+WI.fillTextValue("r_")+" where gs_index = "+
				WI.fillTextValue("gs_")+" and encoded_by = "+(String)request.getSession(false).getAttribute("userIndex");
			if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1)
				strRetResult = "Error Msg : Error updating.";
			else
				strRetResult = "Success. Click Proceed to view changes.";
			break;
		case 208: //Called to update remark in wnu final grade sheet printing..
			strRetResult = new enrollment.ApplicationMgmt().ajaxUpdateApplStatAUF(dbOP, request);
			break;
		case 209: //Called to operate on the grade verification for other than Finals. Link in verify grade.
			enrollment.GradeSystemExtn gsExtn = new enrollment.GradeSystemExtn();
			strRetResult =gsExtn.verifyGradeOthers(dbOP, Integer.parseInt(WI.fillTextValue("action")),request, null, null, null);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+gsExtn.getErrMsg();
			break;
		case 210: //Called to operate on the grade verification for other than Finals. Link in verify grade.
			gsExtn = new enrollment.GradeSystemExtn();
			strRetResult =gsExtn.ajaxViewOneGrade(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+gsExtn.getErrMsg();
			break;
		case 211: //Called to keep session alive..
			//strRetResult = AI.keepSessionAlive(request);//"-- Keeping Session Alive --";
			strRetResult = "-- Keeping Session Alive --";
			break;
		case 212: //CIT call to update the subject eval stat..
			enrollment.FacultyEvaluation facEval = new enrollment.FacultyEvaluation();
			strRetResult =facEval.ajaxToggleSubjectEvalStat(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+facEval.getErrMsg();
			break;
		case 213: //CIT call to update the answer to faculty eval..

			enrollment.FacultyEvaluation facEval2 = new enrollment.FacultyEvaluation();
			strRetResult = facEval2.ajaxUpdateAns(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+facEval2.getErrMsg();
			break;
		case 214: //called to update the TOR line number in otr.jsp.
			enrollment.EntranceNGraduationData entranceData = new enrollment.EntranceNGraduationData();
			strRetResult = entranceData.ajaxUpdateTORLineNumber(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+entranceData.getErrMsg();
			break;
		case 215: //called to update grade unit.. .
			strSQLQuery = null;
			String strIsFinal = WI.fillTextValue("is_final");
			String strNewUnit = WI.fillTextValue("new_gs");
			
			if(strIsFinal.equals("1"))	
				strSQLQuery = " G_SHEET_FINAL";
			else	
				strSQLQuery = " GRADE_SHEET";
			strSQLQuery = "update "+strSQLQuery+" set credit_earned = "+strNewUnit+" where gs_index = "+
						WI.fillTextValue("gs_ref");
			if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1)
				strRetResult = "Error Msg: Failed to update grade units";
			else	
				strRetResult = strNewUnit;
			break;
		case 216: //called by CIT to have advance grade submission.
			gsExtn = new enrollment.GradeSystemExtn();
			if(gsExtn.advanceGrade(dbOP, WI.fillTextValue("section"), (String)request.getSession(false).getAttribute("userIndex"), 0) == null)
				strErrMsg = "Error Msg : "+gsExtn.getErrMsg();
			else	
				strRetResult = " success";
			break;
		case 217: //called by CIT to have advance grade submission.
				if(WI.fillTextValue("pmt_sch").equals("3"))
					strSQLQuery = "g_sheet_final";
				else					
					strSQLQuery = "grade_sheet";
				strSQLQuery = "update "+strSQLQuery+" set FORCE_LOCK_STAT = 2 where gs_index = "+WI.fillTextValue("gs_ref");
				//System.out.println(strSQLQuery);
				if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1)
					strErrMsg = "Error Msg : Failed to Unlock";		
				else	
					strRetResult = " success";
			break;
		case 218: //called by CIT to have advance grade submission.
				enrollment.EACExamSchedule eec = new enrollment.EACExamSchedule();
				if(WI.fillTextValue("update_").length() > 0) 
					strRetResult = eec.ajaxUpdateSched(dbOP, request);
				else
					strRetResult = eec.ajaxLoadRoom(dbOP, request, WI.fillTextValue("sch_ref"), WI.fillTextValue("sel_name"));
					
				if(strRetResult == null) {
					strRetResult = "Error Msg : "+eec.getErrMsg();
				}
			break;
		case 219: //called by CIT to have advance grade submission.
				enrollment.CashDeposit CDeposit = new enrollment.CashDeposit();
				strRetResult = CDeposit.ajaxUpdateBank(dbOP, request);
				if(strRetResult == null) {
					strRetResult = "Error Msg : "+CDeposit.getErrMsg();
				}
			break;
	/**** all about payroll**/ 
		case 300: //called to update loan
			payroll.PRRemittance prR = new payroll.PRRemittance(request);
			if(!prR.updateLoanDateIssue(dbOP))
			 	strRetResult = "Error Msg : "+prR.getErrMsg();
			else
				strRetResult = request.getParameter("new_date");
			break;
		case 301: //called to load salary periods
			strRetResult = prAI.loadSalaryPeriods(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;
 		case 302: //called to load computed tax in for 2316
			strRetResult = prAI.ajaxComputeTax(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;		
 		case 303: //called to update misc ded max or payable balance
			strRetResult = prAI.ajaxUpdateMiscDedAmount(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : " + prAI.getErrMsg();
			break;	
		case 304: 
			strRetResult = prAI.loadClonedSalaryPeriods(dbOP,request);
   			if(strRetResult == null)
				strRetResult = "Error Msg : "+ prAI.getErrMsg();
 			break;
 		case 306: //called to load dept list
			strRetResult = prAI.ajaxLoadDeptList(dbOP, request);
 			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;
 		case 307: //called toggle bank transmittal status
			strRetResult = prAI.toggleBankTransmittalStatus(dbOP, request);
 			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;
 		case 308: //called finalize releasing of bond
			strRetResult = prAI.finalizeBondRelease(dbOP, request);
 			if(strRetResult == null)
				strRetResult = "Error Msg : " + prAI.getErrMsg();
			break;			
			
 		case 309: //called to load earnings
			strRetResult = prAI.ajaxLoadEarning(dbOP, request);
 			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;
 		case 310: //called to search employee ID
			strRetResult = prAI.ajaxSearchEmpID(dbOP, request);
 			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;
		case 311: // called to update loan schedule
			if(!prAI.ajaxUpdateLoanSchedule(dbOP, request))
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			else
					strRetResult = "";
			break;
			
 		case 312: //called to delete loan schedule
			strRetResult = prAI.ajaxDeleteLoanSchedule(dbOP, request);
 			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;						
			
 		case 313: // called to get tax Exemption of a tax status
			strRetResult = prAI.ajaxGetExemption(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;
 		case 314: // called to get tax Exemption of a tax status
			strRetResult = prAI.ajaxLoadLoanList(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+prAI.getErrMsg();
			break;
		/** for kiosk application **/
		case 400: // called to load ledger..
			strRetResult = kioskStudent.ajaxLoadLedger(dbOP, request);
			if(strRetResult == null)
				strRetResult = "<font style='font-size:14px;'>"+kioskStudent.getErrMsg()+"</font>";//"Error Msg : "+
			//System.out.println(strRetResult);
			request.getSession(false).setAttribute("userIndex","0");
		break;
		case 401: // called to load Grade.
			strRetResult = kioskStudent.ajaxLoadGradeInfo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "<font style='font-size:14px;'>"+kioskStudent.getErrMsg()+"</font>";

			request.getSession(false).setAttribute("userIndex","0");
		break;
		case 402: // called to load installment payment
			strRetResult = kioskStudent.ajaxLoadInstallmentPmt(dbOP, request);
			if(strRetResult == null)
				strRetResult = "<font style='font-size:14px;'>"+kioskStudent.getErrMsg()+"</font>";

			request.getSession(false).setAttribute("userIndex","0");
		break;
		case 403: // called to load Internet usage detail
			strRetResult = kioskStudent.ajaxLoadInternetUsage(dbOP, request);
			if(strRetResult == null)
				strRetResult = "<font style='font-size:14px;'>"+kioskStudent.getErrMsg()+"</font>";

			request.getSession(false).setAttribute("userIndex","0");
		break;
		case 404: // called to load Library Account
			strRetResult = kioskStudent.ajaxLoadLibrayInfo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "<font style='font-size:14px;'>"+kioskStudent.getErrMsg()+"</font>";

			request.getSession(false).setAttribute("userIndex","0");
		break;
		case 405: // called to load Internal Mail message.
			strRetResult = kioskStudent.ajaxLoadEmailSummary(dbOP, request);
			if(strRetResult == null)
				strRetResult = "<font style='font-size:14px;'>"+kioskStudent.getErrMsg()+"</font>";

			request.getSession(false).setAttribute("userIndex","0");
		break;
		case 406: // called to load Internal Mail message body - view one msg..
			strRetResult = kioskStudent.ajaxLoadEmailBody(dbOP, request);
			if(strRetResult == null)
				strRetResult = "<font style='font-size:14px;'>"+kioskStudent.getErrMsg()+"</font>";
			request.getSession(false).setAttribute("userIndex","0");
		break;
		//for employee Kiosk.. 
		case 415: // 
			 strRetResult = empKiosk.ajaxLoadMiscDeductions(dbOP, request);
			 if(strRetResult == null)
				  strRetResult = "Error Msg : "+empKiosk.getErrMsg();
			 //request.getSession(false).setAttribute("userIndex","0");
			 break;
		case 416: // 
			 strRetResult = empKiosk.ajaxLoadLoansPayable(dbOP, request);
			 if(strRetResult == null)
				  strRetResult = "Error Msg : "+empKiosk.getErrMsg();
			 //request.getSession(false).setAttribute("userIndex","0");
			 break;
		
		case 417: // 
			 strRetResult = empKiosk.ajaxLoadLoanRecon(dbOP, request);
			 if(strRetResult == null)
				  strRetResult = "Error Msg : "+empKiosk.getErrMsg();
			 //request.getSession(false).setAttribute("userIndex","0");
			 break;
		
	    /*** all about accounting here ********/
		case 501:
			Accounting.AccountPayable AP = new Accounting.AccountPayable();
			strRetResult = AP.ajaxUpdateProcessAPManual(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+AP.getErrMsg();
			break;
		case 502:
			strRetResult = jvCD.updateAjaxLiquidationOrPmtType(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+jvCD.getErrMsg();
			break;
		case 503:
			Accounting.EnrollmentJournal erj = new Accounting.EnrollmentJournal();
			strRetResult = erj.getARInfoOne(dbOP, request);
			if(strRetResult == null) {
				if(erj.getErrMsg() == null)
					strRetResult = "";
				else
					strRetResult = "Error Msg : "+erj.getErrMsg();
			}
			break;
		// edtr for finalizing time logs for a date range
		case 600:
			eDTR.WorkingHour WH = new eDTR.WorkingHour();
			eDTR.ReportEDTRExtn rptExtn = new eDTR.ReportEDTRExtn(request);
 		 	if(!WH.finalizeAwolForDates(dbOP, request))
				strRetResult = "Error Msg : "+ WH.getErrMsg();
			else{
 				if(!rptExtn.convertAwolToUndertime(dbOP, request))
					strRetResult = "Error Msg : "+ rptExtn.getErrMsg();
				else
					strRetResult = "";
			}
			break;
		case 601:	
			strRetResult = dtrAjax.ajaxSearchSubordinate(dbOP, request);
 		 	if(strRetResult == null)
				strRetResult = "Error Msg : "+ dtrAjax.getErrMsg();
			break;		// end edtr
		case 602:	
			strRetResult = dtrAjax.ajaxLoadFacultySchedule(dbOP, request);
 		 	if(strRetResult == null)
				strRetResult = "Error Msg : "+ dtrAjax.getErrMsg();
			break;
		case 603:	// for adding schedule  one by one
 		 	if(!dtrAjax.ajaxAddFacultySchedule(dbOP, request)){
				strRetResult = "Error Msg : "+ dtrAjax.getErrMsg();
				break;	
 			}else{
				strRetResult = dtrAjax.ajaxLoadFacultySchedule(dbOP, request);
				if(strRetResult == null)
					strRetResult = "Error Msg : "+ dtrAjax.getErrMsg();
 			}				
			break;		
		case 604:	// for loading rooms in a list...
			strRetResult = dtrAjax.ajaxLoadRooms(dbOP, request);
 		 	if(strRetResult == null)
				strRetResult = "Error Msg : "+ dtrAjax.getErrMsg();
			break;		// start for locker management
		case 700:	
			strRetResult = lockers.ajaxSearchLockerCode(dbOP, request);
 		 	if(strRetResult == null)
				strRetResult = "Error Msg : "+ lockers.getErrMsg();
			break;		
		// end locker management
	///1000 up are for hospital use.
		case 1000://called to search patient
			strRetResult = AI.quickSearchNameHIS(dbOP, request);
			break;
		case 1001://called to search patient
			strRetResult = AI.genericSearchHIS(dbOP, request);
			break;
	//1400s - for Dale.
		case 1400:
			strRetResult = pam.ajaxSearchAssetCode(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+pam.getErrMsg();
			break;

		case 1401:
			strRetResult = pam.ajaxSearchPropNum(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+pam.getErrMsg();
			break;
		case 1402:
			strRetResult = shf.ajaxSearchSubModule(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+shf.getErrMsg();
			break;
		case 1403:
			strRetResult = shf.ajaxSearchLinks(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+shf.getErrMsg();
			break;
		//////////end of personnel Asset Management and System help file.

		// HR starts at 3000
		case 3000:
			strRetResult = hrAjax.loadCoverageUnit(request);
 		 	if(strRetResult == null)
				strRetResult = "Error Msg : "+ hrAjax.getErrMsg();
			break;
			
		case 3001://called to compute expected leave duration
			strRetResult = hrAjax.computeLeaveDuration(dbOP, request);
 		 	if(strRetResult == null)
				strRetResult = "Error Msg : "+ hrAjax.getErrMsg();
 			break;

		case 3002://called to compute expected leave duration
			strRetResult = hrAjax.ajaxGetLeaveBenefitInfo(dbOP, request);
  			if(strRetResult == null)
				strRetResult = "Error Msg : "+ hrAjax.getErrMsg();
 			break;
		case 3003:// show or hide
		   strRetResult = hrAjax.loadSemOptions(dbOP, request);
		   if(strRetResult == null)
			  strRetResult = "Error Msg : "+ hrAjax.getErrMsg();
		   break;
		case 3004://
			strRetResult = hrAjax.loadSemOptions(dbOP,request);
 			strRetResult += "##########";
			strRetResult += hrAjax.ajaxLoadRemarks(dbOP,request);
   			if(strRetResult == null)
				strRetResult = "Error Msg : "+ hrAjax.getErrMsg();
 			break;		
		case 3005://
			strRetResult = hrAjax.loadSLOptions(request);
   			if(strRetResult == null)
				strRetResult = "Error Msg : "+ hrAjax.getErrMsg();
 			break;
		case 3006:// load separated employees
			strRetResult = hrAjax.ajaxLoadSeparated(dbOP, request);
	   		if(strRetResult == null)
				strRetResult = "Error Msg : "+ hrAjax.getErrMsg();
 			break;
		// end HR
	
		///Accounting for tsuneishi ...
		case 20000:
			strRetResult = billTsu.ajaxSearchBillingNo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+billTsu.getErrMsg();
			break;
		case 20001:
			strRetResult = billTsu.ajaxSearchInvoiceNo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+billTsu.getErrMsg();
			break;
		case 20002:
			strRetResult = budget.ajaxLoadLevels(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg: "+budget.getErrMsg();
			break;
		case 20003:
			strRetResult = sp.ajaxSearchInvoiceSOANo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+sp.getErrMsg();
			break;
		case 20004:
			strRetResult = sm.ajaxSearchSANumber(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+sm.getErrMsg();
			break;
		case 20005:
			strRetResult = sm.ajaxLoadAddress(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+sm.getErrMsg();
			break;
		case 20006:
			strRetResult = sm.ajaxLoadPosition(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+sm.getErrMsg();
			break;
		case 20007:
			strRetResult = sm.ajaxLoadDetails(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+sm.getErrMsg();
			break;
		case 20008:
			strRetResult = sp.ajaxSearchPayments(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+sp.getErrMsg();
			break;
		case 20009:
			strRetResult = tsuDC.ajaxSearchDCNumber(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+tsuDC.getErrMsg();
			break;
		///End for accounting for tsuneishi ...
		
		//20100 - dale project management
		case 20100:
			strRetResult = proj.ajaxSearchClient(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+proj.getErrMsg();
			break;
		case 20101:
			strRetResult = todo.ajaxUpdateCompletion(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+todo.getErrMsg();
			break;
		//20200 - dale visitor management module
		case 20200:
			strRetResult = visitor.ajaxSearchVisitors(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+visitor.getErrMsg();
			break;

		//20300 - dale :: document management system
		case 20229://show detail in ajax.. 
			docTracking.deped.DocReceiveRelease drr= new docTracking.deped.DocReceiveRelease();
			strRetResult = drr.ajaxShowTransDtlsOnline(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+drr.getErrMsg();	
			bolIsLoginReqd = false;		
			break;
		case 20300:
			strRetResult = docType.ajaxSearchTypeCode(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+docType.getErrMsg();			
			break;
		case 20301:
			strRetResult = docType.ajaxSearchDocTypes(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+docType.getErrMsg();
			break;
		case 20302:
			strRetResult = docType.ajaxSearchVersion(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+docType.getErrMsg();
			break;
		//20400 - dale :: utility
		case 20400:
			strRetResult = ga.getGenericAjaxCombo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+ga.getErrMsg();
			break;
		case 20401:
			strRetResult = ga.updateSPRAjax(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+ga.getErrMsg();
			break;
		case 20402:
			strRetResult = ga.updatePreloadAddress(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+ga.getErrMsg();
			else//remove this to get the address as return value.
				strRetResult = "success";
			break;
		case 20403:
			strRetResult = SPDCit.ajaxUpdateLastSchoolAttended(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+SPDCit.getErrMsg();
			break;
		case 20404:
			strRetResult = SPDCit.ajaxEditSchoolInfo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+SPDCit.getErrMsg();
			break;
		case 20500:
			utility.BankPosting bp = new utility.BankPosting();
			strRetResult =  bp.generateORToValue(request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+bp.getErrMsg();
			break;
		//20600 - dale :: invoice (artcraft)
		case 20600:
			strRetResult = cim.ajaxSearchInvoiceNo(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+cim.getErrMsg();
			break;
		//20700 - dale :: bookstore
		case 20700:
			strRetResult = bo.ajaxSearchOrders(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+bo.getErrMsg();
			break;

		//30000 - aaron :: cdd conversion table
		case 30000:
			strRetResult = scaledConv.ajaxGetScaledScore(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+scaledConv.getErrMsg();
			break;
		case 30001:
			strRetResult = scaledConv.ajaxGetIQSSRank(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+scaledConv.getErrMsg();
			break;
		case 30002:
			strRetResult = scaledConv.ajaxGetTotalIQSSRank(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+scaledConv.getErrMsg();
			break;
		case 30003:
			strRetResult = scaledConv.ajaxGetIQDescription(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+scaledConv.getErrMsg();
			break;
		case 40000:
			strRetResult = docReq.ajaxSearchRequest(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+docReq.getErrMsg();
			break;
			

		case 5000: //Load items from selected category
			strRetResult = hmsPOS.ajaxLoadCategoryItems(dbOP, request, true);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();
			break;
			
		case 5001: // add new item
			if(!hmsPOS.getItemInfo(dbOP, request)){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();
				break;
			}
			
			strRetResult = hmsPOS.constructOrderTable(request);
			strRetResult += "##########";
			strRetResult += hmsPOS.constructSummary(dbOP,request);
			strRetResult += "##########";
			strRetResult += hmsPOS.ajaxLoadCategoryItems(dbOP, request, true);	
		break;
		
		case 5002: //
			strTemp = hmsPOS.constructOrderTable(request);		
		 	if(strTemp == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}
			strRetResult = strTemp;			
			strRetResult += "##########";

			strTemp = hmsPOS.constructSummary(dbOP,request);
		 	if(strTemp == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}			
			strRetResult += strTemp;
			strRetResult += "##########";

			strTemp = hmsPOS.ajaxLoadCategories(dbOP, request);
		 	if(strTemp == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}						
			strRetResult += strTemp;
		break;
				
		case 5003: // removing item
			strRetResult = hmsPOS.removeItem(dbOP, request);			
			if(strRetResult == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}
			strRetResult = hmsPOS.constructOrderTable(request);		
			strRetResult += "##########";
			strRetResult += hmsPOS.constructSummary(dbOP, request);			
		break;
		
		
		case 5004: // load the categories in the restaurant
			strRetResult = hmsPOS.ajaxLoadCategories(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();
 		break;
		
		case 5005: // 
			strRetResult = hmsPOS.ajaxLoadCategoryItems(dbOP, request, true);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();
		break;

		case 5007:
			try {				
				int iField1 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field1"),"0"));
				int iField2 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field2"),"0"));
				int iField3 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field3"),"0"));
				int iField4 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field4"),"0"));
				int iField5 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field5"),"0"));
				int iField6 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field6"),"0"));				
				int iTotal1 = iField1 + iField2 + iField3 + iField4 + iField5 + iField6; 	
				//strRetResult = Integer.toString(iTotal1);	
				strRetResult = "<input type='text' style='text-align:center;' name='field_7' value='"+iTotal1+"' class='textbox_noborder' readonly size='5'>";				
			}
			catch(Exception e) {
				strRetResult = "0";		
			}
			break;
		
		case 5008:
			try {			
				int iField8 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field8"),"0"));
				int iField9 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field9"),"0"));
				int iField10 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field10"),"0"));
				int iField11 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field11"),"0"));
				int iField12 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field12"),"0"));
				int iField13 = Integer.parseInt(WI.getStrValue(WI.fillTextValue("field13"),"0"));				
				int iTotal2 = iField8 + iField9 + iField10 + iField11 + iField12 + iField13;				
				//strRetResult = Integer.toString(iTotal2);		
				strRetResult = "<input type='text' style='text-align:center;' name='field_14' value='"+iTotal2+"' class='textbox_noborder' readonly size='5'>";		
			}
			catch(Exception e) {
				strRetResult = "0";		
			}
			break;
		
		case 6200://MPC School Days Present for SPR
			strRetResult = WI.fillTextValue("new_val");
			strTemp = "update stud_curriculum_hist set MPC_SPR_SCHOOL_DAYS = "+strRetResult+
				" where cur_hist_index = "+WI.fillTextValue("cur_hist_index");
	
			if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1)
				strRetResult = "Error in processing";		
		break;
		case 6201:
			strRetResult = WI.fillTextValue("new_val");
			if(strRetResult.length() == 0)
				strRetResult = "0";
			strTemp = "update stud_curriculum_hist set COMPETENCY_INDEX = "+strRetResult+
				" where cur_hist_index = "+WI.fillTextValue("cur_hist_index");
			if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1)
				strRetResult = "Error in processing";
			break;
		case 6300:
			strRetResult = WI.fillTextValue("new_value");
			strTemp = "update pur_delivery set RECEIVING_NO = "+strRetResult+
				" where DELIVERY_INDEX = "+WI.fillTextValue("delivery_index");			
			if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1)
				strRetResult = "Error in processing";
			break;		
							
		case 6400:
			strRetResult = ESExtn.ajaxAddEvaluationScore(dbOP, request, WI.fillTextValue("eval_personnel_index"));
			if(strRetResult == null)
				strRetResult = ESExtn.getErrMsg();			
			break;
		case 6401:
			strRetResult = ESExtn.ajaxAddEvaluationComment(dbOP, request, WI.fillTextValue("eval_personnel_index"));
			if(strRetResult == null)
				strRetResult = ESExtn.getErrMsg();			
			break;
		case 6406:
				inventory.InvPreventiveMaintenance invMaint = new inventory.InvPreventiveMaintenance();
				strRetResult = invMaint.getAjaxNextMaintenanceSchedule(dbOP, request);
				if(strRetResult == null)
					strRetResult = "Error Msg : "+ invMaint.getErrMsg();
			break;
	}

}
catch(Exception e) {
	strRetResult = "";
}
//clean up here.
if(dbOP != null)
	dbOP.cleanUP();
////write obj here..
if(strErrMsg == null)
	strErrMsg = AI.getErrMsg();
if(strRetResult == null)
	strRetResult = "Error Msg : "+strErrMsg;

//if logged out, I must put relaod to 1
if(bolIsLoginReqd && request.getSession(false).getAttribute("userIndex") == null)
	strRetResult = "You are already logged out. Please login again.";

response.getWriter().print(strRetResult);

%>
