<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.is_reloaded.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.is_reloaded.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
<!--
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID()
{
	document.form_.stud_id.focus();
}
-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDMoral, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vBasicInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrPurpose = {"School Transfer", "Employment", "Examination Requirement"};
	String[] astrStatus = {"Under Evaluation", "Given to Studemt"};


	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Good Moral Certification-Certification Request Entry","cert_req_entry.jsp");
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
														"Guidance & Counseling","Good Moral Certification",request.getRemoteAddr(),
														"cert_req_entry.jsp");
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
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0) 
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));

String strCourse = "";
if (vBasicInfo == null)
	strCourse = "";
else 
	strCourse = (String)vBasicInfo.elementAt(5);

if (vBasicInfo!=null && vBasicInfo.size()>0){
	GDMoral GDMor = new GDMoral();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDMor.operateOnMoralCertification(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = GDMor.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = GDMor.operateOnMoralCertification(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = GDMor.getErrMsg();
	}

	vRetResult = GDMor.operateOnMoralCertification(dbOP, request, 4);
	
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDMor.getErrMsg();
}
else
	strErrMsg = OAdm.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./cert_req_entry.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: GOOD MORAL CERTIFICATION : CERTIFICATION 
          REQUEST ENTRY PAGE::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="5%">&nbsp;</td>
      <td width="20%">Enter Student ID : 
	  <td width="40%">
	 <%
	 if (vEditInfo!=null && vEditInfo.size()>0) 
		 	strTemp = (String)vEditInfo.elementAt(1);
	 	else
			strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><a href="javascript:StudSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="35%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      </tr>
      </table>
      <%if (vBasicInfo!= null && vBasicInfo.size()>0){
	strTemp =(String)vBasicInfo.elementAt(19);
    %>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"> <div align="right"> 
          <hr size="1">
        </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Brithdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4" valign="middle"><strong>I - Purpose :</strong></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td height="25" colspan="4" width="95%"> <font size="1"><font size="1"> 
        <%
        if (vEditInfo!=null && vEditInfo.size()>0 && WI.fillTextValue("is_reloaded").length()==0)
	        strTemp = (String)vEditInfo.elementAt(5);
        else
    	    strTemp = (String)WI.fillTextValue("purpose_index");%>
        <select name="purpose_index" onChange="javascript:ReloadPage();">
            <option value="0" selected>Transfer to other school</option>
            <%if (strTemp.compareTo("1")==0){%>
            	<option value="1" selected>For employment</option>
			<%}else{%>
				<option value="1">For employment</option>
			<%} if (strTemp.compareTo("2")==0){%>
	            <option value="2" selected>Examination requirement</option>
	        <%}else{%>
	        	<option value="2">Examination requirement</option>
	        	<%}%>
          </select>
       </td>
    </tr>
    </table>
    <%//System.out.println(request.getParameter("purpose_index"));
    if (strTemp.compareTo("0")==0 || request.getParameter("purpose_index") == null ){%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	 <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="31">&nbsp;</td>
      <td height="31" colspan="4" valign="middle"><strong>II - Provide the information 
        below if Purpose of Request is <em><u>&quot;Transfer to other school&quot;</u></em>:</strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="4" >&nbsp;
        To shift to another course which is not offered by the school </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Desired course : &nbsp;&nbsp;&nbsp;&nbsp;  
      <%
      if (vEditInfo!=null && vEditInfo.size()>0)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(6),"");
      else
	     strTemp = WI.fillTextValue("des_course");%>
     <input name="des_course" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Name of School :&nbsp;&nbsp; &nbsp; 
      <%
      if (vEditInfo != null && vEditInfo.size()>0)
      	strTemp = WI.getStrValue((String)vEditInfo.elementAt(7),"");
      else
	    strTemp = WI.fillTextValue("school_name");%>
     <input name="school_name" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Address of School : 
      <%
      if (vEditInfo!=null && vEditInfo.size()>0)
	      strTemp = WI.getStrValue((String)vEditInfo.elementAt(8),"");
      else
    	  strTemp = WI.fillTextValue("school_addr");%>
     <input name="school_addr" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="128"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
       <%String strTempRes = null;
        if (vEditInfo!= null && vEditInfo.size()>0)
            strTempRes = (String)vEditInfo.elementAt(9); 
      	else
	        strTempRes = WI.fillTextValue("reason1");
        if (strTempRes.compareTo("1")==0)
        	strTemp = "checked";
       	else 
        	strTemp ="";%>
      <input type="checkbox" name="reason1" value="1" <%=strTemp%>>
        Inadequate school facilities and equipment</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
      <%
        if (vEditInfo!= null && vEditInfo.size()>0)
            strTempRes = (String)vEditInfo.elementAt(10); 
      	else
	        strTempRes = WI.fillTextValue("reason2");
        if (strTempRes.compareTo("1")==0)
        	strTemp = "checked";
       	else 
        	strTemp ="";%>
      <input type="checkbox" name="reason2" value="1">
        Poor curriulum</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
       <%
        if (vEditInfo!= null && vEditInfo.size()>0)
            strTempRes = (String)vEditInfo.elementAt(11); 
      	else
	        strTempRes = WI.fillTextValue("reason3");
        if (strTempRes.compareTo("1")==0)
        	strTemp = "checked";
       	else 
        	strTemp ="";%>
      <input type="checkbox" name="reason3" value="1" <%=strTemp%>>
        Poor instruction</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
       <%
        if (vEditInfo!= null && vEditInfo.size()>0)
            strTempRes = (String)vEditInfo.elementAt(12); 
      	else
	        strTempRes = WI.fillTextValue("reason4");
        if (strTempRes.compareTo("1")==0)
        	strTemp = "checked";
       	else 
        	strTemp ="";%>
      <input type="checkbox" name="reason4" value="1" <%=strTemp%>>
        Change of residence</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;
        Others (please specify) 
        <%
        if(vEditInfo!=null && vEditInfo.size()>0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(13),"");
    	else
    	   strTemp = WI.fillTextValue("others");%>
     <input name="others" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="128"></td>
    </tr>
    </table>
    <%}
    else if (strTemp.compareTo("1")==0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><strong>II - Provide the information below 
        if Purpose of Request is <em><u>&quot;Employment&quot;</u></em>:</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Name of prospective employer 
         <%
         if(vEditInfo!=null && vEditInfo.size()>0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(14),"");
    	else
         strTemp = WI.fillTextValue("employer");%>
     <input name="employer" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
        <td height="25" colspan="4">Name of business 
         <%
          if(vEditInfo!=null && vEditInfo.size()>0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(15),"");
    	else
         strTemp = WI.fillTextValue("bus_name");%>
     <input name="bus_name" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">Position desired  
      <%
       if(vEditInfo!=null && vEditInfo.size()>0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(16),"");
    	else
	      strTemp = WI.fillTextValue("pos_desired");%>
     <input name="pos_desired" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
</table>
<%} else if (strTemp.compareTo("2")==0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4"><strong>II - Provide the information below if 
        Purpose of Request is <em><u>&quot;Examination Requirement&quot;</u></em>:</strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4">Name of examination 
         <%
          if(vEditInfo!=null && vEditInfo.size()>0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(17),"");
    	else
           strTemp = WI.fillTextValue("exam_name");%>
     <input name="exam_name" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4">Place of examination&nbsp; 
       <%
        if(vEditInfo!=null && vEditInfo.size()>0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(18),"");
    	else
    	   strTemp = WI.fillTextValue("exam_place");%>
     <input name="exam_place" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="128">
      </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="3">Date of examination&nbsp; 
	 <%
	  if(vEditInfo!=null && vEditInfo.size()>0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(19),"");
    	else
		   strTemp = WI.fillTextValue("exam_date");%>
     <input name="exam_date" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="32">
	</td>
    </tr>
    </table>
    <%}%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">Date of Request : <%
	  if(vEditInfo!=null && vEditInfo.size()>0 && WI.fillTextValue("is_reloaded").length()==0)
	       strTemp = (String)vEditInfo.elementAt(2);
    	else
		   strTemp = WI.fillTextValue("exam_date");
	   
	   if (strTemp.length()==0)
		   strTemp = WI.getTodaysDate(1);%>
        <input name="request_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.request_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
        </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4">Tentative Release Date :
        <%
	  if(vEditInfo!=null && vEditInfo.size()>0 && WI.fillTextValue("is_reloaded").length()==0)
	       strTemp = WI.getStrValue((String)vEditInfo.elementAt(20),WI.getTodaysDate(1));
    	else
		   strTemp = WI.fillTextValue("release_date");
		   
	if (strTemp.length()==0)
		   strTemp = WI.getTodaysDate(1);%>
        <input name="release_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.release_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4">Request Status : 
        <%
        if (vEditInfo!=null && vEditInfo.size()>0 && WI.fillTextValue("is_reloaded").length()==0)
	        strTemp = (String)vEditInfo.elementAt(21);
        else
    	    strTemp = (String)WI.fillTextValue("status_index");%>
        <select name="status_index">
            <option value="0" selected>Under evaluation</option>
            <%if (strTemp.compareTo("1")==0){%>
            	<option value="1" selected>Given to student</option>
			<%}else{%>
				<option value="1">Given to student</option>
			<%}%>
          </select>
        <%
	  if(vEditInfo!=null && vEditInfo.size()>0 && WI.fillTextValue("is_reloaded").length()==0)
	       strTemp = (String)vEditInfo.elementAt(22);
    	else
		   strTemp = WI.fillTextValue("update_date");
		   
		   if (strTemp.length()==0)
		   strTemp = WI.getTodaysDate(1);%>
        <input name="update_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.update_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="48">&nbsp;</td>
      <td height="48" colspan="4" valign="bottom"><div align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></div></td>
    </tr>
  </table>
  <%}%>
   <%if (vRetResult != null && vRetResult.size()>0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#D8D569"> 
      <td height="24" colspan="6" class="thinborder"><div align="center"><font color="#000000">LIST OF REQUESTS</font></div></td>
    </tr>
    <tr> 
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>DATE REQUESTED</strong></font></div></td>
      <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PURPOSE</strong></font></div></td>
      <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
      <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong>RELEASE DATE</strong></font></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">OPTIONS</font></strong></div></td>
    </tr>
<%for (int i = 0; i< vRetResult.size(); i+=23){%>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td height="25" class="thinborder"><div align="center"><%=astrPurpose[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></div></td>
      <td height="25" class="thinborder"><div align="center"><%=astrStatus[Integer.parseInt((String)vRetResult.elementAt(i+21))]%></div></td>
      <td height="25" class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+20), "Not Defined")%></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>Not authorized to edit<%}%></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>Not authorized to delete<%}%></font></div></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="3%" height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>
	<input name = "course_index" type = "hidden"  value="<%=strCourse%>">
 	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="is_reloaded">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>