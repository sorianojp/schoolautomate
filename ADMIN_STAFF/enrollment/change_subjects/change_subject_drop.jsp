<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strStudID = WI.fillTextValue("stud_id");
	int iMaxDisplayed = 0;
	boolean bolFatalErr = false;

	boolean bolIsRegistrar = WI.fillTextValue("registrar").equals("1");

	String strAuthTypeIndex = WI.getStrValue((String)request.getSession(false).getAttribute("authTypeIndex"));
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	String strSYFrom   = null;
	String strSYTo     = null;
	String strSemester = null;
	
	strSYFrom = WI.fillTextValue("sy_from");
	if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	
	strSYTo = WI.fillTextValue("sy_to");
	if(strSYTo.length() ==0)
		strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	
	strSemester = WI.fillTextValue("semester");
	if(strSemester.length() ==0)
		strSemester = (String)request.getSession(false).getAttribute("cur_sem");
	
	boolean bolIsOnlineAdvising = false;//called from online advising. --> I have to also check if student is allowed to add/drop.. 
	if(WI.fillTextValue("online_advising").length() > 0 && strAuthTypeIndex.equals("4")) {
			bolIsOnlineAdvising = true;
			strStudID = (String)request.getSession(false).getAttribute("userId");
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.chngsubject.submit();
}
function Withdraw()
{

	var iMaxDisplay = Number(document.chngsubject.max_display.value);
	var iCount = 0;
	var iWGrade = 0;
	var objChkBox;

	for (var iIndex = 0; iIndex < iMaxDisplay; iIndex++){
		eval("objChkBox=document.chngsubject.checkbox"+iIndex);

		if(!objChkBox)
			++iWGrade;
		else if (objChkBox.checked)
			iCount++;
	}
	if(iCount != iMaxDisplay && document.chngsubject.force_drop_all.value == '1') {
		alert('All subjects must be dropped.');
		return;
	}
	
	
	if (iCount > 0){
		if(iCount < iMaxDisplay) {
			<%if(!bolIsRegistrar){%>
				if(document.chngsubject.reason.value.length == 0)
					document.chngsubject.reason.value = "Withdraw Subject.";
			<%}else{%>
				if(document.chngsubject.reason.value.length == 0) {
					alert("Please enter reason for Dropping.");
					return;
				}
			<%}%>
		}
		if(iCount == iMaxDisplay) {
			if(document.chngsubject.reason.value.length > 0) {
				document.chngsubject.withdraw.value="1";
				document.chngsubject.hide_save.src = "../../../images/blank.gif";
				ReloadPage();
				return;
			}
			else {
				alert("Please enter reason for Dropping.");
				return;
			}
		}
		else if (confirm(" Drop the " + iCount + " subject(s) "))	{
			document.chngsubject.withdraw.value="1";
			document.chngsubject.hide_save.src = "../../../images/blank.gif";
			ReloadPage();
		}


	}else{
		alert ("Select Subjects to drop");
	}

}
function SubtractLoad(index,subLoad)
{
//alert(subLoad+",,, "+document.advising.sub_load.value);
	//add if clicked and if not clicked remove it.
	if( eval("document.chngsubject.checkbox"+index+".checked") )
	{
		document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) - eval(subLoad);
		if(document.chngsubject.sub_load.value == 0)
		{
			var vProceed = confirm("Click OK to Drop all subject.");
			if(!vProceed) {
				//alert("Student can't withdraw all subjects.");
				document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) + eval(subLoad);
				eval("document.chngsubject.checkbox"+index+".checked=false");
				return;
			}
			else {
				this.Withdraw();
				return;
			}
		}
	}
	else //subtract.
		document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) + eval(subLoad);


	if( eval(document.chngsubject.sub_load.value) < 0)
		document.chngsubject.sub_load.value = 0;

}
function FocusID() {
<%if(!bolIsOnlineAdvising){%>
	document.chngsubject.stud_id.focus();
<%}%>
}
function OpenSearch() {
<%if(!bolIsOnlineAdvising){%>
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=chngsubject.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
<%}%>
}
function RemoveFromList(strIndex) {
	document.chngsubject.remove_fr_list.value = "1";
	document.chngsubject.remove_index.value   = strIndex;
	ReloadPage();
}
function GoToAdd() {

	var strNoCharge = document.chngsubject.no_charge.value;
	if(!strNoCharge == "1")
		strNoCharge = "";
	else
		strNoCharge = "no_charge=1&";

	location = "./change_subject_add.jsp?"+strNoCharge+"sy_from="+document.chngsubject.sy_from.value+"&sy_to="+document.chngsubject.sy_to.value+
		"&semester="+document.chngsubject.semester[document.chngsubject.semester.selectedIndex].value+
		"&stud_id="+document.chngsubject.stud_id.value+"&online_advising="+document.chngsubject.online_advising.value;;
}
<%if(!bolIsOnlineAdvising){%>
function ChangeSubStat(strEnrollRef, strSubRef, strCurRef, bolIsDrop) {
	if(!confirm('Are you sure you want to change subject status.'))
		return;
	<%if(!strSchCode.startsWith("AUF") && !strSchCode.startsWith("DLSHSI")){%>
		if(bolIsDrop && document.chngsubject.remark_i.selectedIndex == 0)  {
			alert("Please select a remark.");
			return;
		}
	<%}%>
	document.chngsubject.change_stat_enroll_index.value = strEnrollRef;
	document.chngsubject.change_stat_sub_index.value    = strSubRef;
	document.chngsubject.change_stat_cur_index.value    = strCurRef;

	document.chngsubject.update_sub_stat.value='1';
	document.chngsubject.submit();
}
<%}%>
function ConfirmAdd() {
	<%if(strSchCode.startsWith("UC") || bolIsRegistrar){%>
		return;
	<%}%>
	if(document.chngsubject.drop_success.value == 'true') {
		if(!confirm('Click OK to Add Subject. Cancel to Stay in this page.'))
			return;
		GoToAdd();
	}
}
function UpdateAddDropCount() {
	return;
	var obj = document.chngsubject.no_of_adddrop;
	if(!obj)
		return;
	if(document.chngsubject.no_of_adddrop_edited.value != '')
		return;
	
	var iCount = 0;
	for(var i = 0; i< document.chngsubject.max_display.value; ++i) {
		if( eval('document.chngsubject.checkbox'+i+'.checked'))
			++iCount;
	}
	if(iCount > 0) 
		obj.value = iCount;

}
<%if(!bolIsOnlineAdvising){%>
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.chngsubject.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.chngsubject.stud_id.value = strID;
	document.chngsubject.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.chngsubject.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
<%}%>

function PrintFinalClassSchedule() {
	var strStudID   = document.chngsubject.stud_id.value;
	var strSYFrom   = document.chngsubject.sy_from.value;
	var strSYTo     = document.chngsubject.sy_to.value;
	var strSemester = document.chngsubject.semester.value;
	
	if(strStudID == '') {
		alert("Please enter student ID.");
		return;
	}
	if(strSYFrom == '' || strSYFrom == '') {
		alert("Please enter SY From/To.");
		return;
	}
	if(strSemester == '') {
		alert("Please enter Semester");
		return;
	}

	var pgLoc = "../../fee_assess_pay/payment/enrollment_receipt_print_uc_batch.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+
		strSemester+"&stud_id="+strStudID;
		
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();ConfirmAdd();">
<%
	int j=0; //this is the max display variable.
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS","change_subject_drop.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 0;
if(bolIsOnlineAdvising) 
	iAccessLevel = 2;
else {
	if(bolIsRegistrar) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","Drop Subject",request.getRemoteAddr(),
															"change_subject_drop.jsp");
	}
	else {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
															"change_subject_drop.jsp");
	}
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
boolean bolIsSuperUser = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));

//end of authenticaion code.
//--- I have to check if the student is allowed to add/drop.. 
if(bolIsOnlineAdvising) {
	if(!strSchCode.startsWith("NEU")) {
		if(!new enrollment.OverideParameter().isAllowedAddDrop(dbOP, (String)request.getSession(false).getAttribute("userIndex"), strSYFrom, strSemester)) {
			bolFatalErr = true;
			strErrMsg = "You are not allowed to process add/drop. Please open adding/droping for current date.";
		}	
	}
}


String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

Vector vEnrolledList = new Vector();
Vector vStudInfo = new Vector();


String strNoChargeForADD = "0";//if student adds after drop, it is considered as one transaction..
boolean bolIsDropSuccess = false;

Advising advising = new Advising();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
enrollment.FAFeeMaintenance FFM = new enrollment.FAFeeMaintenance();

Vector vDroppedSubList = null;//only if Show only Dropped subject list is clicked.

if(strStudID.length() > 0 && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && !bolFatalErr)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),strStudID,
                                    WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = enrlAddDropSub.getErrMsg();
	}
	else {
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;
	}
	if(!bolFatalErr)
	{
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),
			WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4),WI.fillTextValue("semester"),(String)vStudInfo.elementAt(7),
			(String)vStudInfo.elementAt(8));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
		{
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1)
				strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
				" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		}
	}
	//Withdraw subject if it is trigged.
	if(!bolFatalErr && WI.fillTextValue("withdraw").compareTo("1") ==0)
	{
		if(enrlAddDropSub.dropSubject(dbOP,request)) {
				dbOP.forceAutoCommitToTrue();
				if(!FFM.chargeAddDropFeeApplicable(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"), (String)vStudInfo.elementAt(4), (String)request.getSession(false).getAttribute("userIndex"), false, request)) {
					strErrMsg = "Subjects dropped Successfully. But Drop Charge Failed to post to ledger. Please manually post.";
				}
				else {
					strErrMsg = "Subject/s dropped successfully.";
					strNoChargeForADD = "1";
					bolIsDropSuccess = true;
				}
//			strErrMsg = "Subject(s) dropped successfully.";
		}
		else
		{
			bolFatalErr = true;
			strErrMsg =enrlAddDropSub.getErrMsg();
		}
	}
	else if(!bolFatalErr && WI.fillTextValue("remove_fr_list").compareTo("1") ==0)
	{
		if(enrlAddDropSub.removeDroppedSubRecord(dbOP,WI.fillTextValue("remove_index"),(String)request.getSession(false).getAttribute("userId")) )
			strErrMsg = "Subject removed from dropped list.";
		else
		{
			bolFatalErr = true;
			strErrMsg =enrlAddDropSub.getErrMsg();
		}
	}
	else if(!bolFatalErr && WI.fillTextValue("update_sub_stat").length() > 0) {
		if(enrlAddDropSub.dropSubjectChangeStatOnly(dbOP,request) )
			strErrMsg = "Subject status updated.";
		else
			strErrMsg =enrlAddDropSub.getErrMsg();
	}
	if(!bolFatalErr && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) // show enrolled list
	{
		if(WI.fillTextValue("show_dropped").length() == 0) {
			vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
	                    WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"),false,true);
			if(vEnrolledList ==null)
			{
				bolFatalErr = true;
				strErrMsg = enrlAddDropSub.getErrMsg();
			}
		}
		else {
			vDroppedSubList = enrlAddDropSub.getAddedDroppedList(dbOP, (String)vStudInfo.elementAt(0),  (String)vStudInfo.elementAt(9),
											 request.getParameter("sy_from"),request.getParameter("sy_to"),
											 request.getParameter("semester"), false);
			if(vDroppedSubList == null)
				strErrMsg = enrlAddDropSub.getErrMsg();
		}
	}
}

boolean bolIsCGH = strSchCode.startsWith("CGH");
boolean bolIsCIT = strSchCode.startsWith("CIT");
boolean bolIsSWU = strSchCode.startsWith("SWU");
boolean bolIsAUF = strSchCode.startsWith("AUF");
boolean bolIsDLSHSI = strSchCode.startsWith("DLSHSI");

boolean bolShowWGrade = false;
//if(strSchCode.startsWith("PWC"))
//	bolShowWGrade = true;
if(bolIsSWU || strSchCode.startsWith("PWC"))
	bolShowWGrade = true;
else if(bolIsRegistrar && (bolIsCIT || bolIsAUF || bolIsDLSHSI))
	bolShowWGrade = true;

//boolean bolIsAllowedToAddDrop = true;
/****/
boolean bolIsAllowedToAddDrop = false;
if(!bolFatalErr && vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.SetParameter sP = new enrollment.SetParameter();
	if(!sP.isLockedGeneric(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), "3", (String)vStudInfo.elementAt(0), "0"))
		bolIsAllowedToAddDrop = true;
	else
		strErrMsg = "Add/Drop already closed. Please contact System admin.";
}
//**/

//for CIT, do not drop the subjects PE and NSTP if not added in excption.. 
Vector vSubjNotAllowedToDrop = new Vector();
if(bolIsAllowedToAddDrop && strSchCode.startsWith("CIT") && vEnrolledList != null && vEnrolledList.size() > 0) {
	 int iYrLevel = Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0"));
	 if(iYrLevel >= 2) {
		String strSQLQuery = "select sub_code from subject where (sub_Code like 'pe%' or sub_code like 'nstp%') and is_del = 0 "+
			" and not exists (select * from CIT_DROP_NSTPPE_EXCEPTION where is_valid = 1 and SY_F = "+WI.fillTextValue("sy_from")+" and sem = "+WI.fillTextValue("semester")+
			" and sub_i = subject.sub_index and stud_index = "+vStudInfo.elementAt(0)+" and employee_index = "+(String)request.getSession(false).getAttribute("userIndex")+
			" and (last_date is null or last_date >='"+WI.getTodaysDate()+"')) order by sub_code";
		//System.out.println(strSQLQuery);
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			if(iYrLevel == 2 && rs.getString(1).startsWith("NSTP"))
				continue;
			vSubjNotAllowedToDrop.addElement(rs.getString(1));
		} 
		rs.close();
	 }
	 //System.out.println(vSubjNotAllowedToDrop);
}


//i have to check if student has enrolled to block section, if enrolled, must b foreced to drop all.
String strForceDropALL = "0";
if(vEnrolledList != null && vEnrolledList.size() > 0) {
	enrollment.SubjectSection SS = new enrollment.SubjectSection();
	Vector vForcedBlock = SS.getForcedBlockSectionList(dbOP, request, request.getParameter("sy_from"), request.getParameter("semester"));
	if(vForcedBlock != null && vForcedBlock.size() > 0) {
		 for(int i=1;i<vEnrolledList.size(); i += 15){
		 	//System.out.println(vEnrolledList.elementAt(i+7));
		 	if(vForcedBlock.indexOf(WI.getStrValue(vEnrolledList.elementAt(i+7),"N/A")) > -1) {
				strForceDropALL = "1";
				break;
			}
		 }
	}
}

%>

<form action="./change_subject_drop.jsp" method="post" name="chngsubject"  onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          CHANGE OF SUBJECTS - DROP / WITHDRAW ::::</strong></font></strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(true && !bolIsOnlineAdvising) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
<%if(!bolIsCIT) {%>
	<%
	  strTemp = WI.fillTextValue("error_enrl");
	  if(strTemp.compareTo("1") == 0)
	  	strTemp = " checked";
	  else
	  	strTemp = "";
	%>
	  <input type="checkbox" name="error_enrl" value="1"<%=strTemp%>>
        <font color="#0000FF"><strong>Drop reason is due to error in Enrollment.</strong></font>
<%}%>		</td>
      <td height="25">
        <%
	  strTemp = WI.fillTextValue("show_dropped");
	  if(strTemp.compareTo("1") == 0)
	  	strTemp = " checked";
	  else
	  	strTemp = "";
	%>
        <input type="checkbox" name="show_dropped" value="1"<%=strTemp%> onChange="ReloadPage();">
        <font color="#0000FF"><strong>Show the dropped subjects.</strong></font></td>
      <td align="right"><a href="javascript:GoToAdd();"><font style="font-size:11px; font-weight:bold; color:#FF0000">Go To Add</font></a>&nbsp;</td>
    </tr>
<%if(!bolIsCGH){%>
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" align="right" style="color:#FF0000;font-weight:bold">Remark in TOR/Grade Sheet&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td height="25">
	  <select name="remark_i">
	  <option value="0">Donot record grade</option>
        <%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0 and is_internal=1 and remark not like 'pass%' and remark not like 'fail%' and remark not like 'Inc%'" ,null , false)%>
      </select></td>
      <td>&nbsp;</td>
	</tr>
<%}

}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25">Enter Student ID </td>
      <td width="15%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.getStrValue(strStudID)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   <%if(bolIsOnlineAdvising) {%> style="border:0px; font-size:18px;" readonly="yes"<%}else{%> onKeyUp="AjaxMapName('1');"<%}%>>      </td>
      <td width="20%"><%if(!bolIsOnlineAdvising) {%><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><%}%></td>
      <td width="40%" height="25">
	   <!--
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  -->
	  <input type="submit" name="Reload" value="Reload Page">   </td>
      <td width="10%">&nbsp;</td>
    </tr>
    <tr>
      <td></td>
      <td colspan="5"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td> 
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY-Term </td>
      <td height="25" colspan="2">  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("chngsubject","sy_from","sy_to")'<%if(bolIsOnlineAdvising){%> readonly='yes'<%}%>>
        to
       
	    <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
<%if(bolIsOnlineAdvising){%>
		<option value="<%=strSemester%>"><%=astrConvertSem[Integer.parseInt(strSemester)]%></option>
<%}else{%>
          <option value="0">Summer</option>
          <%
if(strSemester.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strSemester.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) {
		  if(strSemester.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  %>
<%}%>
       </select> <input type="hidden" name="offering_sem_name" value="<%=astrConvertSem[Integer.parseInt(strSemester)]%>">  </td>
      <td height="25" colspan="2">
	  <%if (strSchCode.startsWith("UC")) {%>
	  	<input type="button" name="122" value="Print Final Class Schedule" style="font-size:14px; height:28px;border: 1px solid #FF0000;" onClick="PrintFinalClassSchedule();">
	  <%}%>
	  </td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5" style="font-size:9px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="dr_keep_subj"> Change Subject Status to Dropped (Keep subject in Enrolled subject list and insert selected grade to all grading period) </td>
    </tr>
-->
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr  && vEnrolledList != null && vEnrolledList.size() > 0){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td colspan="5" height="25"><hr size="1">
	  <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>"></td>
    </tr>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Student name </td>
      <td width="40%"> <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td width="14%">Date approved </td>
      <td width="25%">
<%
strTemp = WI.fillTextValue("apv_date");
if(strTemp.length() == 0 || bolIsOnlineAdvising)
	strTemp = WI.getTodaysDate(1);
%>	  <input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(!bolIsOnlineAdvising) {%>
        <a href="javascript:show_calendar('chngsubject.apv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major</td>
      <td height="25" colspan="3"><strong><%=(String)vStudInfo.elementAt(2)%>
        <%
		if(vStudInfo.elementAt(3) != null){%>
        / <%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Year level</td>
      <td height="25" colspan="3"><strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong>
	  <input type="hidden" name="year_level" value="<%=WI.getStrValue(vStudInfo.elementAt(4))%>"></td>
    </tr>
    <tr >
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">SUBJECTS
          ENROLLED</font></div></td>
    </tr>
<%if(strSchCode.startsWith("UC")){
strTemp = FFM.getAddDropFeeRef(dbOP, WI.fillTextValue("sy_from"), true);
if(strTemp != null) {
strTemp = "select amount from fa_oth_sch_fee where othsch_fee_index = "+strTemp;
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null)
	strTemp = CommonUtil.formatFloat(strTemp, true);
%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25" style="font-size:16px; font-weight:bold; color:#0000FF">Number of  Charge(s):
	    <input type="text" name="no_of_adddrop" size="3" value="1" <%if(!bolIsSuperUser && false){%>readonly="yes"<%}%> maxlength="2" style="font-weight:bold;font-size:18px; color:#0000FF;font-family:Verdana, Arial, Helvetica, sans-serif;" onKeyUp="document.chngsubject.no_of_adddrop_edited.value='1'">
	  x <%=strTemp%>
	  </td>
    </tr>
<%}
}
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
<%}%>

    <tr >
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td  colspan="2" height="25">Total student load :
<input type="text" name="sub_load" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=(String)vEnrolledList.elementAt(0)%>"></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="16%" height="27" align="center"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="26%" align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="4%" align="center"><font size="1"><strong>LEC. UNITS</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>LAB. UNITS</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>TOTAL UNITS</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>SECTION</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>ROOM #</strong></font></td>
      <td width="18%" align="center"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="9%" align="center"><font size="1"><strong>DROPPED / WITHDRAW</strong></font></td>
      <%if(bolShowWGrade){%><td width="5%" align="center">Change Status to Dropped </td><%}%>
    </tr>
 <%
 boolean bolIsDropStatSet = false;
 String strBGColor = "";

 boolean bolAllowDropNSTPPE = true;

 for(int i=1;i<vEnrolledList.size();++i,++j){
 	if(enrlAddDropSub.vDropSubList.indexOf(vEnrolledList.elementAt(i)) > -1) {
		bolIsDropStatSet = true;
		strBGColor = " bgcolor='#FF0000'";
	}
	else {
		bolIsDropStatSet = false;
		strBGColor = " ";
	}

	bolAllowDropNSTPPE = true;
	if( vSubjNotAllowedToDrop.indexOf(vEnrolledList.elementAt(i+3)) > -1)
		bolAllowDropNSTPPE = false;
	%>
    <tr<%=strBGColor%>>
      <td height="25"><%=(String)vEnrolledList.elementAt(i+3)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+4)%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+11),"&nbsp;")%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+12),"&nbsp;")%></td>
      <td><%=(String)vEnrolledList.elementAt(i+13)%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+7),"N/A")%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+8),"N/A")%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+6),"N/A")%></td>
      <td><div align="center">
	  <%if(!bolAllowDropNSTPPE){%>
	  	Not Allowed
	<%}else if(!bolIsDropStatSet) {//do not let drop if already changed stat..
		if(vEnrolledList.elementAt(i) != null && !((String)vEnrolledList.elementAt(i)).equals("0")){%>
				  <input type="checkbox" name="checkbox<%=j%>" value="checkbox" onClick='SubtractLoad("<%=j%>","<%=(String)vEnrolledList.elementAt(i+13)%>")'>
				</div>
		<%}else {--j;%>
		<a href="./re_enrolment.jsp?stud_id=<%=WI.fillTextValue("stud_id")%>&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>">DROP</a>
		<%}
	}else{%>&nbsp;
	<%}%>
			  <!-- all the hidden fileds are here. -->
	  <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+13)%>">
	  <input type="hidden" name="enrl_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i)%>">
	  <input type="hidden" name="sub_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+2)%>">
	  <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+1)%>">	  </td>
<%if(bolShowWGrade){%>
      <td align="center"><input type="button" name="_" value="W Grade" style="font-size:11px;" onClick="ChangeSubStat('<%=vEnrolledList.elementAt(i)%>','<%=(String)vEnrolledList.elementAt(i+2)%>','<%=(String)vEnrolledList.elementAt(i+1)%>', <%=!bolIsDropStatSet%>)"></td>
<%}%>
    </tr>
<%
i = i+14;
}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
<%if(bolIsAllowedToAddDrop) {%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="20%" valign="top">Reason for dropping: </td>
      <td width="40%" valign="top"><textarea name="reason" cols="40" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea></td>
      <td width="36%" valign="bottom">
	  <a href="javascript:Withdraw();">
	  <img src="../../../images/save.gif" border="0" name="hide_save" onClick="UpdateAddDropCount();"></a><font size="1">click
        to save changes</font></td>
    </tr>
<%}%>
  </table>
<%}//when student info is not null;

 if (vDroppedSubList != null && vDroppedSubList.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="28" colspan="6">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF">
      <td height="25" colspan="7" class="thinborder"><div align="center"><strong>LIST
          OF DROPPED SUBJECTS</strong></div></td>
    </tr>
    <tr>
      <td width="15%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Subject</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Section</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>Units</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>Date Approved</strong></font></div></td>
      <td width="35%" class="thinborder"><div align="center"><font size="1"><strong>Reason For Dropping</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Dropped By</strong></font></div></td>
      <td width="10%" class="thinborder" align="center"><font size="1"><strong>Remove from Drop List</strong></font></td>
    </tr>
    <% for (int i = 0; i < vDroppedSubList.size(); i+=18){%>
    <tr>
      <td height="25" class="thinborder" align="center"><font size="1"><%=(String)vDroppedSubList.elementAt(i+2)%></font></td>
      <td class="thinborder" align="center"><font size="1"><%=(String)vDroppedSubList.elementAt(i+6)%></font></td>
      <td class="thinborder" align="center"><font size="1"><%=(String)vDroppedSubList.elementAt(i+12)%></font></td>
      <td class="thinborder" align="center"><font size="1"><%=WI.getStrValue((String)vDroppedSubList.elementAt(i+14),"&nbsp")%></font></td>
      <td class="thinborder" align="center"><font size="1"><%=WI.getStrValue((String)vDroppedSubList.elementAt(i+15),"&nbsp")%></font></td>
      <td class="thinborder" align="center"><font size="1"><%=(String)vDroppedSubList.elementAt(i+16)%></font></td>
      <td class="thinborder" align="center"><a href="javascript:RemoveFromList(<%=(String)vDroppedSubList.elementAt(i)%>);"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}//end for loop%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
   <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="withdraw" value="0">
<input type="hidden" name="max_display" value="<%=j%>">
<input type="hidden" name="remove_fr_list">
<input type="hidden" name="remove_index">

<!-- for changing subject status -->
<input type="hidden" name="change_stat_enroll_index">
<input type="hidden" name="change_stat_sub_index">
<input type="hidden" name="change_stat_cur_index">
<input type="hidden" name="update_sub_stat">


<!-- if no charge = 1, do not charge for add -->
<input type="hidden" name="no_charge" value="<%=strNoChargeForADD%>">
<!-- if drop_success = true, as question if want to add -->
<input type="hidden" name="drop_success" value="<%=bolIsDropSuccess%>">

<input type="hidden" name="no_of_adddrop_edited" value="">


<input type="hidden" name="registrar" value="<%=WI.fillTextValue("registrar")%>">


<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">
<input type="hidden" name="force_drop_all" value="<%=strForceDropALL%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
