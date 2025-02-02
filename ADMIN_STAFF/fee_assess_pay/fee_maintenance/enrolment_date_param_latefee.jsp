<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strInfoIndex,iAction) {
	document.form_.page_action.value = iAction ;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}
//function 
function ReloadPage() {
	this.SubmitOnce('form_');
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-FEE MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Fee Assessment & Payments-enrolment date param","enrolment_date_param.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

FAFeeMaintenanceVairable fmVariable = new FAFeeMaintenanceVairable();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(fmVariable.operateOnLateFineAddl(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = fmVariable.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
//get all information from table for the current sem.
vRetResult = fmVariable.operateOnLateFineAddl(dbOP, request, 4);


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsDLSHSI = strSchCode.startsWith("DLSHSI");

%>

<form name="form_" action="./enrolment_date_param_latefee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: ENROLMENT
          LATE FINE DATE PARAMETERS PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="22%">School Year/Term</td>
      <td width="30%">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp; <select name="semester" >
          <option value="">ALL</option>
          <%
strTemp =WI.fillTextValue("semester");
if(request.getParameter("semester") == null) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="45%"><input name="image" type="image" src="../../../images/refresh.gif">
      </td>
    </tr>
    <tr>
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolIsDLSHSI){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="4">
		<select name="college_i" style="font-size:12px; font-family:Verdana, Arial, Helvetica, sans-serif; width:400; background:#CCCCCC">
          <option></option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_del=0 order by c_name asc", WI.fillTextValue("college_i"), false)%> 
        </select>
		</td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Payment schedule</td>
      <td colspan="4">
	  <select name="pmt_sch_index">
	  	<option value="0">DownPayment</option>
          <%=dbOP.loadCombo("pmt_sch_index","exam_name"," from fa_pmt_schedule order by exam_period_order asc", WI.fillTextValue("pmt_sch_index"), false)%>  
	  </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>If paid on or after </td>
      <td width="75%" colspan="4"><font size="1">
        <input name="lf_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("lf_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.lf_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%">Fine amount</td>
      <td colspan="4"><input name="fine_amt" type="text" size="6"
	  value="<%=WI.fillTextValue("fine_amt")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress="AllowOnlyInteger('form_','fine_amt');"></td>
    </tr>
    <tr> 
      <td height="25"> <div align="left"></div></td>
      <td height="25" colspan="5"> <%
if(iAccessLevel > 1 && WI.fillTextValue("view_only").length() == 0){%> <a href='javascript:PageAction("",1);'><img src="../../../images/save.gif" border="0"></a> 
        <font size="1">click to add/save entries &nbsp;</font> <%}else{%>
        ONLY VIEW PERMITTED 
        <%}%> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="45%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#BBDDFF">
      <td width="100%" height="25" colspan="5" class="thinborderTOPBOTTOMRIGHT" align="center" style="font-weight:bold">::: LATE FEE INFORMATION LIST ::: </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">PAYMENT SCHEDULE</td>
<%if(bolIsDLSHSI){%>
      <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">COLLEGE</td>
<%}%>
      <td width="25%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ON OR AFTER</td>
      <td width="25%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">FINE AMOUNT</td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
    <%//System.out.println(vRetResult.size());System.out.println(vRetResult);
	for(int i = 0 ; i< vRetResult.size() ; i += 10){
		strTemp = (String)vRetResult.elementAt(i + 1);
		if(strTemp.equals("0"))
			strTemp = "DownPayment";
		else	
			strTemp = (String)vRetResult.elementAt(i + 7);//payment schedule.
		
	%>
    <tr> 
      <td class="thinborder"><%=strTemp%></td>
<%if(bolIsDLSHSI){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "All")%></td>
<%}%>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i + 6)),true)%></td>
      <td class="thinborder"> <%if(iAccessLevel ==2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        N/A 
        <%}%> </td>
    </tr>
    <%}%>
  </table>
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
 <input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>