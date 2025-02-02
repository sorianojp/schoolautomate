<%@ page language="java" import="utility.*, health.MedicationMgmt,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script>
<!--
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;

	String [] astrRelation = {"Parent", "Guardian"};	
	
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iSearchResult = 0;

	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Medications Management","authorization.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Health Monitoring","Medications Management",request.getRemoteAddr(),
														"authorization.jsp");
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

//end of authenticaion code.
Vector vBasicInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//called for adde,edit or delete.

}
//get all levels created.
if(WI.fillTextValue("stud_id").length() > 0) {
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		strErrMsg = OAdm.getErrMsg();
	}
	else {//check if student is currently enrolled
		Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
		(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
		if(vTempBasicInfo != null)
			bolIsStudEnrolled = true;
	}

}



	MedicationMgmt medMgmt = new MedicationMgmt();
	strTemp = WI.fillTextValue("page_action");

	if(strTemp.length() > 0) {
		if(medMgmt.operateOnGuardianConsent(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				vBasicInfo = null;
				strPrepareToEdit = "";
				}
		else
				strErrMsg = medMgmt.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
    	vEditInfo = medMgmt.operateOnGuardianConsent(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = medMgmt.getErrMsg();
	}
	

	vRetResult = medMgmt.operateOnGuardianConsent(dbOP, request, 4);
	iSearchResult = medMgmt.getSearchCount();
	if (strErrMsg == null)
		strErrMsg = medMgmt.getErrMsg();
%>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<form action="./authorization.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td width="61%" height="28" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MEDICATIONS MANAGEMENT - PARENT/GUARDIAN AUTHORIZATION ENTRY PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td  width="2%"height="23" bgcolor="#FFFFFF"><font size="1">&nbsp;</font></td>
      <td width="17%" height="23" bgcolor="#FFFFFF"><font size="1">Student ID</font></td>
       <%
       if (vEditInfo!=null && vEditInfo.size()>0)
    	   	strTemp = (String)vEditInfo.elementAt(1);
       else
	       strTemp = WI.fillTextValue("stud_id");%>
      <td width="12%" height="23" bgcolor="#FFFFFF"> <font size="1"> 
      <input type="text" name="stud_id" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
        </font></td>
      <td width="69%" height="23" bgcolor="#FFFFFF"><font size="1"><a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a><font size="1">Search for student</font></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
    	<td height="23">&nbsp;</td>
    	<td>&nbsp;</td>
    	<td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    	<td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
    </table>
     <%
if(vBasicInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" > <%if(bolIsStudEnrolled){%>
        Currently Enrolled <%}else{%>
        Not Currently Enrolled <%}%></td>
    </tr>
    <tr>
      <td   height="25">&nbsp;</td>
      <td >Course/Major :</td>
      <td height="25" colspan="3" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year :</td>
      <td ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
   <tr> 
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%}%>
    
     <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF"><font size="1">&nbsp;</font></td>
      <td bgcolor="#FFFFFF"><font size="1">Authorized by</font></td>
      <td colspan="2" bgcolor="#FFFFFF"><font size="1"> 
        <%
        if (vEditInfo != null && vEditInfo.size()>0)
        		strTemp = (String)vEditInfo.elementAt(5);
	        else
    		    strTemp = WI.fillTextValue("auth_by");%>
      <input type="text" name="auth_by" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="64"> 
        </font></td>
    </tr>
    <tr bgcolor="#697A8F">
    	<td height="25" bgcolor="#FFFFFF"></td>
    	<td bgcolor="#FFFFFF"><font size="1">Contact Information</font></td>
    	<td colspan="2" bgcolor="#FFFFFF"> 
    	<% 
    	if (vEditInfo != null && vEditInfo.size()>0)
    			strTemp = (String) vEditInfo.elementAt(6);
    		else 
		    	strTemp = WI.fillTextValue("contact_info");	%>
		<textarea name="contact_info" cols="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur='style.backgroundColor="white"'><%=strTemp%></textarea></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF"><font size="1">&nbsp;</font></td>
      <td bgcolor="#FFFFFF"><font size="1">Relationship</font></td>
      <td colspan="2" bgcolor="#FFFFFF"><font size="1"> 
        <%if (vEditInfo != null && vEditInfo.size()>0)
        		strTemp = (String)vEditInfo.elementAt(7);
        	else 
        		strTemp = WI.fillTextValue("rel");
        %>
        <select name="rel">
	      <option value="">Select Relationship</option>
          <%if (strTemp.compareTo("0")==0){%>
	          <option value="0" selected>Parent</option>
	       <%}else{%>
	          <option value="0">Parent</option>
	          <%} if (strTemp.compareTo("1")==0){%>
		          <option value="1" selected>Guardian</option>
	       <%}else{%>
                  <option value="1">Guardian</option>
    		<%}%>
        </select>
        </font></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF"><font size="1">&nbsp;</font></td>
      <td bgcolor="#FFFFFF"><font size="1"> Date Auth. Given</font></td>
      <td colspan="2" bgcolor="#FFFFFF"><font size="1"> 
        <%
		if (vEditInfo!=null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(8);
		else
			strTemp = WI.fillTextValue("auth_date");
		
		 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);
		%>
		<input name="auth_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.auth_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </font> </td>
    </tr>
       <%if(vBasicInfo != null){%>
    <tr bgcolor="#697A8F"> 
      <td height="48" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
     <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong><font size="1">LIST 
          OF STUDENTS WITH AUTHORIZATION</font></strong></div></td>
    </tr>
     <tr> 
      <td colspan="3" class="thinborder"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TOTAL 
        :<strong><%=iSearchResult%></strong></font></td>
      <td colspan="5" class="thinborder"><font size="1"><div align="right">
      <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/medMgmt.defSearchSize;
		if(iSearchResult % medMgmt.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}}%>
          </select>
          <%} else {%>&nbsp;<%}%></font></div>
       </td>
    </tr>
    <tr> 
      <td width="15%" height="26" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          ID </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>AUTHORIZED BY</strong></font></div></td>
      <td width="21%" class="thinborder"><div align="center"><font size="1"><strong>CONTACT INFO</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>RELATIONSHIP</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>DATE </strong></font></div></td>
      <td width="4%" class="thinborder"><font size="1">&nbsp;</font></td>
      <td width="4%" class="thinborder">&nbsp;</td>
    </tr>
       <%for(int i =0; i<vRetResult.size(); i+=9){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "None")%></font></td>
      <td class="thinborder"><font size="1"><%=astrRelation[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"> 
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"> 
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%></font></div></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
