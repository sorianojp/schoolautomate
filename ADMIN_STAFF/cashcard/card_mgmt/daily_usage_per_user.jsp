<%@ page language="java" import="utility.*,cashcard.CardManagement, java.util.Vector "%>
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
<title>User Max Usage</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strInfo,strAction){
		if(strAction == '0'){
			if(!confirm("Do you want to delete this entry?"))
				return;
		}
		
		if(strInfo.length > 0)
			document.form_.info_index.value = strInfo;
		
		document.form_.page_action.value = strAction;
		this.ReloadPage();
	}
	
	function ReloadPage(){
		document.form_.submit();
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
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	//authenticate this user.
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
								"Admin/staff-Cash Card-Card Management","card_setting.jsp");
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
	
	boolean bolIsBasic = false;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};//not currently used..
	//String[] astrConvertYrLevelBasic = {"N/A", "Nursery", "Kinder I", "Kinder II", "Grade I", "Grade II", "Grade III", "Grade IV", 
	//									"Grade V", "Grade VI", "Grade VII", "First Year", "Second Year", "Third Year", "Fourth Year"};
	
	Vector vRetResult = new Vector();;
	Vector vStudInfo = null;
	
	
	CardManagement cm = new CardManagement();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(cm.operateOnCardSetting(dbOP, request, Integer.parseInt(strTemp)) == null )
			strErrMsg = cm.getErrMsg();
		else {
			if(strTemp.equals("1"))
				strErrMsg = "Card setting successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Card setting successfully edited.";
		}
	}
	

	String strStudID = WI.fillTextValue("stud_id");
	
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;
	boolean bolBasicStudent = false;
	
	
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
		else
			strErrMsg = "Please provide ID Number.";
		
		if(vStudInfo != null){
		
			
		
			String strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
			
			
			strTemp = WI.fillTextValue("page_action");
			
			if(strTemp.length() > 0){
				if(  cm.operateOnUserMaxUsage(dbOP, request, Integer.parseInt(strTemp),strUserIndex) == null )
					strErrMsg = cm.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Entry successfully deleted.";
					if(strTemp.equals("1"))
						strErrMsg = "Entry successfully saved.";
				}					
			}
			
			
			vRetResult = cm.operateOnUserMaxUsage(dbOP, request, 4,strUserIndex);
			if(vRetResult == null)
				strErrMsg = cm.getErrMsg();			
		}
	
	
%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./daily_usage_per_user.jsp" method="post">

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="4" align="center">
				<font color="#FFFFFF"><strong>:::: USER MAX USAGE PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">ID Number:</td>
			<td width="16%">
			<input type="text" name="stud_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="20" onKeyUp="AjaxMapName();" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>"/>			</td>
		   <td width="64%">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" /></a>
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
			<td width="17%">Student Name : </td>
			<td width="43%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4)%></strong></td>
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
			<td width="17%">Emp. Name :</td>
			<td width="43%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),4)%></strong></td>
			<td width="13%">Emp. Status :</td>
			<td width="24%"><strong><%=(String)vStudInfo.elementAt(16)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office :</td>
			<td><strong><%=WI.getStrValue(vStudInfo.elementAt(13))%>/<%=WI.getStrValue(vStudInfo.elementAt(14))%></strong></td>
			<td>Designation :</td>
			<td><strong><%=(String)vStudInfo.elementAt(15)%></strong></td>
		</tr>
	<%}//only if staff %>
	<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	


	
	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Max Usage/Day:</td>
			<td colspan="2">
				<%
					if(vRetResult!= null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(1);//usage amount.
					else
						strTemp = WI.fillTextValue("max_usage_per_day");
						
					strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true), ",", "");
					if(strTemp.equals("0"))
						strTemp = "";
				%>
				<input type="text" name="max_usage_per_day" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','max_usage_per_day');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','max_usage_per_day')" size="16" maxlength="16" 
					value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Alert Amount:</td>
			<td colspan="2">
				<%
					if(vRetResult!= null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(2);//alert amount.
					else
						strTemp = WI.fillTextValue("alert_below");
						
					strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true), ",", "");
					if(strTemp.equals("0"))
						strTemp = "";
				%>
				<input type="text" name="alert_below" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','alert_below');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','alert_below')" size="16" maxlength="16" 
					value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="40">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2">				
				<a href="javascript:PageAction('','1')"><img src="../../../images/save.gif" border="0" /></a>
				<font size="1">Click to save card setting.</font>
			</td>
		</tr>

	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: CARD MAX USAGE/DAY ::: </strong></div></td>
		</tr>
		<tr>  
			<td width="34%" height="25" align="center" class="thinborder"><strong>Max Usage/Day </strong></td> 
			<td width="34%" align="center" class="thinborder"><strong>Alert Amount </strong></td> 
		   <td width="32%" align="center" class="thinborder"><strong>DELETE</strong></td>
		</tr>
		<tr>  
			<td height="25" class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(1), true)%></td> 
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(2), true)%></td> 
		   <td class="thinborder" align="center"><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(0)%>','0');"><img src="../../../images/delete.gif" border="0" /></a></td>
		</tr>
	</table>
<%}


}//end of vStudInfo%>
			
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
		<tr bgcolor="#FFFFFF">
			<td height="25"></td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>