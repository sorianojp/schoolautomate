<%@ page language="java" import="utility.*,cashcard.CardManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Block User Management Page</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PrepareToEdit(strInfoIndex){
		document.form_.page_action.value = "";
		document.form_.info_index.value = strInfoIndex;
		document.form_.prepareToEdit.value = "1";
		document.form_.submit();
	}

	function PageAction(strAction,strInfoIndex){
		document.form_.page_action.value = strAction;
		document.form_.info_index.value = strInfoIndex;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.stud_id.focus();
	}
	
	function AjaxMapName() {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=-1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		/** do not do anything **/
		document.form_.stud_id.value = strID;
		document.form_.submit();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
		//document.form_.charge_to_name.value = strName;
	}
	
	function UpdateNameFormat(strName) {
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function RefreshPage(){
		document.form_.reason.value = "";
		this.SearchStudent();
	}
	
	function SearchStudent(){		
		document.form_.prepareToEdit.value= "";
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";		
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-CARD MANAGEMENT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Card Management","block_user_management.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strLastRecord = null;
	Vector vEditInfo  = null;
	Vector vRetResult = null;

	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertYrLevelBasic = {"N/A", "Nursery", "Kinder I", "Kinder II", "Grade I", "Grade II", "Grade III", "Grade IV", 
										"Grade V", "Grade VI", "Grade VII", "First Year", "Second Year", "Third Year", "Fourth Year"};

	CardManagement cm = new CardManagement();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	Vector vStudInfo = null;
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;
	boolean bolBasicStudent = false;
	/**
	enrollment.FAPaymentUtil pmtUtil = new enrollment.FAPaymentUtil();
	String strStudID = WI.fillTextValue("stud_id");
	if(strStudID.length() > 0) {
		vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
		if(vStudInfo == null) {//may be this is basic student..
			bolIsBasic = true;
			pmtUtil.setIsBasic(bolIsBasic);
			vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
		}
		if(vStudInfo == null) 
			strErrMsg = pmtUtil.getErrMsg();
	}
	**/
	String strStudID = WI.fillTextValue("stud_id");
	if(strStudID.length() > 0) {
		if(bolIsSchool) {
			vStudInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
			if(vStudInfo == null) //may be it is the teacher/staff
			{
				request.setAttribute("emp_id",request.getParameter("stud_id"));
				vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				if(vStudInfo != null)
					bolIsStaff = true;
			}
			else {//check if student is currently enrolled
				Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
				(String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(9));
				if(vTempBasicInfo != null){
					bolIsStudEnrolled = true;
					if(((String)vTempBasicInfo.elementAt(5)).equals("0"))
						bolBasicStudent = true;
					//System.out.println("vTempBasicInfo: "+vTempBasicInfo);
				}
			}
			if(vStudInfo == null)
				strErrMsg = OAdm.getErrMsg();
		}
		else{//check faculty only if not school...
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vStudInfo != null)
				bolIsStaff = true;
			if(vStudInfo == null)
				strErrMsg = "Employee Information not found.";
		}
	}

	if(vStudInfo != null) {
		String strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
	
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0) {
			if(cm.operateOnBlockUser(dbOP, request, Integer.parseInt(strTemp), strUserIndex) == null )
				strErrMsg = cm.getErrMsg();
			else {
				if(strTemp.equals("1"))
					strErrMsg = "User successfully blocked.";
				else if(strTemp.equals("2"))
					strErrMsg = "User successfully unblocked";
					
				strPrepareToEdit = "0";
			}
		}
	
		if(strPrepareToEdit.equals("1")) {
			vEditInfo = cm.operateOnBlockUser(dbOP, request,3, strUserIndex);
			if(vEditInfo == null)
				strErrMsg = cm.getErrMsg();
		}
		//view all
		vRetResult = cm.operateOnBlockUser(dbOP, request, 4, strUserIndex);	
		if (vRetResult == null && strTemp.length() == 0)
			strErrMsg = cm.getErrMsg();
			
		strLastRecord = cm.getLastBlockRecord(dbOP, request, strUserIndex);
	}//only if vStudInfo is not null;
%>		
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./block_user_management.jsp" method="post">

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF">
				<strong>:::: BLOCK USER MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25" >&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25" >&nbsp;</td>
			<td width="15%">ID Number: </td>
			<td width="82%">
				<input name="stud_id" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();" value="<%=strStudID%>" size="16">
				&nbsp;&nbsp;&nbsp;
				<a href="javascript:SearchStudent();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				&nbsp;&nbsp;&nbsp;
				<label id="coa_info" style="width:300px; position:absolute"></label>
			</td>
		</tr>
	</table>

<%if(vStudInfo != null) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if(!bolIsStaff){%>
    	<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="15%">Student Name : </td>
			<td width="45%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4)%></strong></td>
			<td width="13%">Status : </td>
			<td width="24%"><%if(bolIsStudEnrolled){%>Currently Enrolled<%}else{%>Not Currently Enrolled<%}%></td>
		</tr>
	<%if(!bolBasicStudent){%>	
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major :</td>
			<td height="25" colspan="3">
				<%
					strTemp = WI.getStrValue((String)vStudInfo.elementAt(7));
					strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(8));
					if(strErrMsg.length() > 0)
						strTemp += "/" + strErrMsg;
				%>
		    <%=strTemp%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Year :</td>
			<td colspan="3">
				<%
					if(bolBasicStudent)
						strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(14)));
					else
						strTemp = astrConvertYrLevel[Integer.parseInt((String)vStudInfo.elementAt(14))];
				%>
				<%=strTemp%></td>
		</tr>
	<%}else{%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="15%">Emp. Name :</td>
			<td width="45%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),4)%></strong></td>
			<td width="13%">Emp. Status :</td>
			<td width="24%"><strong><%=(String)vStudInfo.elementAt(16)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office :</td>
			<td>
				<%
					strTemp = WI.getStrValue((String)vStudInfo.elementAt(13));
					strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(14));
					if(strErrMsg.length() > 0)
						strTemp += "/" + strErrMsg;
				%>
				<strong><%=strTemp%></strong></td>
			<td>Designation :</td>
			<td><strong><%=(String)vStudInfo.elementAt(15)%></strong></td>
		</tr>
	<%}//only if staff %>
	</table>

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">	
		<tr>
			<td width="3%">&nbsp;</td>
			<td width="15%" valign="top"><br>Reason:</td>
			<td width="82%">
				<textarea name="reason" cols="65" rows="4" class="textbox" style="font-size:12px"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td>
				<%if(strLastRecord != null) {//if user is blocked, place unblock button%>	
					<a href="javascript:PageAction(2,'<%=strLastRecord%>');"><img src="../../../images/reactivate_user.gif" border="0"></a>		
					<font size="1">click to unblock user</font>&nbsp; 
				<%}else{%>
				<a href="javascript:PageAction(1, '');"><img src="../../../images/block_user.gif" border="0"></a>
				<font size="1">click to block user</font>&nbsp;	
				<%}%>
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">click to refresh page</font>&nbsp;	</td>	
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: USER BLOCK/UNBLOCK HISTORY LIST ::: </strong></div></td>
		</tr>
		<tr>  
			<td height="25" width="60%" align="center" class="thinborder"><strong>Block/Unblock Reason</strong></td> 
			<td width="15%" align="center" class="thinborder"><strong>Status</strong></td> 
			<td width="15%" align="center" class="thinborder"><strong>Posted By</strong></td> 
			<td width="10%" align="center" class="thinborder"><strong>Date Created</strong></td> 
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 6){%>
		<tr> 
			<td height="25" class="thinborder">
				<%
					strTemp = (String)vRetResult.elementAt(i + 5);
					
					if(strTemp != null)//if unblocked, get the unblock reason
						strTemp = (String)vRetResult.elementAt(i + 2); 
					else//if blocked, get block reason
						strTemp = (String)vRetResult.elementAt(i + 1);
				%>
				<%=strTemp%></td>
			<td align="center" class="thinborder">
				<%
					strTemp = (String)vRetResult.elementAt(i + 5);
					if(strTemp != null){%>
						Unblock 
				<%}else{%>
					<font color="#FF0000">Block</font>
				<%}%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
		</tr>
	<%}%>
	</table>
<%}//end of vRetResult%>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#FFFFFF">
			<td height="25">&nbsp;</td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>