<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
  /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:8;
	top:8;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }

body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
table.thinborder{
	border-top : solid  1px #BB0004;
	border-right : solid 1px #BB0004;
}

TD.thinborder {
    border-left: solid 1px #BB0004;
    border-bottom: solid 1px #BB0004;
} 
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.show_list.value = "1";
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function SelALL() {
	var strIsChecked = false;
	if(document.form_.sel_all.checked)
		strIsChecked = true;
	var iMaxDisp = document.form_.max_disp.value;
	if(eval(iMaxDisp) > 500)
		alert("Please be informed, this operation may take few seconds.");
		
	var vObj;
	for(i = 0; i < eval(iMaxDisp); ++i) {
		eval('vObj=document.form_.checkbox_'+i);
		if(!vObj)
			continue;
		if(strIsChecked)
			vObj.checked = true;
		else	
			vObj.checked =false;
	}
}
function PostFine() {
	if(!confirm("Are you sure you want to remove fines posted?"))
		return;

	document.form_.show_list.value='1';
	document.form_.page_action.value = '1';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Post Charges","post_charges_new_pn_posted.jsp");
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
														"Fee Assessment & Payments","Post Charges",request.getRemoteAddr(),
														"post_charges_new_pn_posted.jsp");
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
enrollment.FAFeePost feePost = new enrollment.FAFeePost();
Vector vStudList      = null;
java.sql.ResultSet rs = null; 
boolean bolIsSuccess  = false;
String strSQLQuery    = null;
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;


String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo   = strSYTo = Integer.toString(Integer.parseInt(strSYFrom) + 1);
String strSemester = WI.fillTextValue("semester");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");

String strPmtSchIndex    = WI.getStrValue(WI.fillTextValue("pmt_schedule"), "0");
String strOthSchFeeIndex = null;
String strOthSchFeeName  = null;
if(strPmtSchIndex.equals("0"))
	strOthSchFeeName  = "PN Fine - Downpayment";
else if(strPmtSchIndex.equals("2"))
	strOthSchFeeName  = "PN Fine - Midterm";
else if(strPmtSchIndex.equals("3"))
	strOthSchFeeName  = "PN Fine - Finals";
else if(strPmtSchIndex.equals("4"))
	strOthSchFeeName  = "PN Fine - First Grading";
else if(strPmtSchIndex.equals("5"))
	strOthSchFeeName  = "PN Fine - Second Grading";
else if(strPmtSchIndex.equals("6"))
	strOthSchFeeName  = "PN Fine - Third Grading";
else if(strPmtSchIndex.equals("7"))
	strOthSchFeeName  = "PN Fine - Fourth Grading";
	
String strSYIndex = "select sy_index from fa_schyr where sy_from = "+strSYFrom;
strSYIndex = dbOP.getResultOfAQuery(strSYIndex, 0);

strSQLQuery = "select othsch_Fee_index from fa_oth_sch_Fee where fee_name = '"+strOthSchFeeName+"' and (sy_index is null or sy_index = "+strSYIndex+
				") order by othsch_Fee_index desc";
strOthSchFeeIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strOthSchFeeIndex == null) {
	strErrMsg = "Name of fine not found";
	strOthSchFeeName = strErrMsg;
}
else {
	if(WI.fillTextValue("page_action").length() > 0) {
		if(feePost.postPNFineNEU(dbOP, request, strOthSchFeeIndex, 0) == null)
			strErrMsg = feePost.getErrMsg();
		else
			strErrMsg = "Posted Fine Removed Successfully.";
	}

	if(WI.fillTextValue("show_list").length() > 0) {
		vStudList = feePost.postPNFineNEU(dbOP, request, strOthSchFeeIndex, 5);
		if(vStudList == null && strErrMsg == null)
			strErrMsg = feePost.getErrMsg();
	}
}


%>
<form name="form_" action="./post_charges_new_pn_posted.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: 
          Post Other School Fees Page - PN Fine Posted ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
      <td valign="top" align="right">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" width="2%">&nbsp;</td>
      <td width="14%" >School Year</td>
      <td width="24%"> 
 <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
 <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
	  <select name="semester">
<%
if(strSemester.compareTo("0") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="0"<%=strErrMsg%>>Summer</option>
<%if(strSemester.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%if(strSemester.compareTo("2") == 0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%if(strSemester.compareTo("3") == 0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select></td>
      <td width="60%" style="font-weight:bold; font-size:14px;">
	  Amount Posted: 200.00		  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Payment Schedule </td>
      <td>
<%
if(bolIsBasic)
	strTemp = "2";
else
	strTemp = "1";
%>
	  <select name="pmt_schedule" onChange="document.form_.show_list.value='';document.form_.submit();">
	  <option value="0">Downpayment</option>
	  <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid="+strTemp+" and pmt_sch_index > 1 order by EXAM_PERIOD_ORDER asc",
		WI.fillTextValue("pmt_schedule"), false)%>
	  </select>	  </td>
      <td style="font-weight:bold; font-size:14px;"><%=strOthSchFeeName%></td>
    </tr>
    
    
    <tr >
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><input name="12345" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1';document.form_.page_action.value = ''" 
	  		value="Show List of Student With PN Fine >>"></td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td height="18">&nbsp;</td>
      <td >&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
<%if(vStudList != null && vStudList.size() > 0 ) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong>::: List of Student to Post Charge ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="7" class="thinborder" style="font-size:10px; font-weight:bold">&nbsp;
	  Total Display : <%=vStudList.size()/8%></td>
    </tr>
    <tr>
      <td style="font-size:10px; font-weight:bold" align="center" width="5%" class="thinborder">Count# </td> 
      <td height="25" style="font-size:10px; font-weight:bold" align="center" width="15%" class="thinborder">Student ID</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="25%" class="thinborder">Student Name</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder"><%if(bolIsBasic){%>Grade Level<%}else{%>Course-YR<%}%></td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Date Posted </td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Posted By </td>
      <td style="font-size:10px; font-weight:bold" align="center" width="5%" class="thinborder">Select ALL<br>
        <input type="checkbox" name="sel_all" onClick="SelALL();" value="checked" <%=WI.fillTextValue("sel_all")%>></td>
    </tr>
    <%for(int i = 0; i < vStudList.size(); i += 8){%>
		<tr>
		  <td class="thinborder"><%=i/8 + 1%></td>
		  <td height="25" class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i)%></td>
		  <td class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i + 1)%></td>
		  <td class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i + 2)%><%=WI.getStrValue((String)vStudList.elementAt(i + 3), "-","","")%></td>
		  <td class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i + 4)%></td>
		  <td class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i + 5)%></td>
		  <td class="thinborder" align="center">&nbsp;<input type="checkbox" name="checkbox_<%=i/8%>" value="<%=vStudList.elementAt(i + 7)%>"></td>
		</tr>
	<%}%>
  </table>
  <input type="hidden" name="max_disp" value="<%=vStudList.size()/8%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center">
			<input name="12345222" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="PostFine();" value="Delete Post Charges">
	  </td>
    </tr>
  </table>
<%}//if vStudList is not null%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="5" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action">
 <input type="hidden" name="show_list">
 <input type="hidden" name="is_basic" value="<%=WI.fillTextValue("is_basic")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
