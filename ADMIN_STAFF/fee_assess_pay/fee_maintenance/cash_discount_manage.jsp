<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.print_pg.value = "";
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
function ShowResult() {
	document.form_.print_pg.value = "";
	document.form_.reloadPage.value = "";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.


	String strErrMsg = null;
//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE","cash_discount_manage.jsp");
	}
	catch(Exception exp) {
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"cash_discount_manage.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.

Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("reloadPage").length() ==0) {
	enrollment.ReportFeeAssessment REA = new enrollment.ReportFeeAssessment();
	
	strTemp = WI.fillTextValue("page_action");
	System.out.println(strTemp);
	if(strTemp.length() > 0) {
		if(REA.operateOnFullPmtCashDiscount(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = REA.getErrMsg();
		else	
			strErrMsg = "Request processed successfully.";
	}

	vRetResult = REA.operateOnFullPmtCashDiscount(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = REA.getErrMsg();	
}
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Year Level"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","stud_curriculum_hist.year_level"};

String[] astrConvertToSem = {"SUMMER, ","FIRST SEMESTER, ","SECOND SEMESTER, ",
						"THIRD SEMESTER, ","FOURTH SEMESTER, "};

%>
<form action="./cash_discount_manage.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: MANAGE CASH DISCOUNT ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25"></td>
      <td colspan="5"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="5" style="font-weight:bold; font-size:11px; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%>> Process Grade School </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="4">SY-Term:  
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>      </td>

      <td width="44%" style="font-size:11px; font-weight:bold; color:#0000FF">Note: AR must be initialized before processing this report </td>
    </tr>
    
    <tr> 
      <td height="25"></td>
      <td colspan="5"><strong>Show By:</strong>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <font color="#0000FF">
		  <input type="checkbox" name="show_processed" value="checked" <%=WI.fillTextValue("show_processed")%>> Show Processed(Modified)	  
		&nbsp;&nbsp;&nbsp;&nbsp;		  
		  <input type="checkbox" name="show_having_bal" value="checked" <%=WI.fillTextValue("show_having_bal")%>> Show having Balance
		&nbsp;&nbsp;&nbsp;&nbsp;		  
		  <input type="checkbox" name="show_zero_discount" value="checked" <%=WI.fillTextValue("show_zero_discount")%>> Show List having Zero Cash Discount	  
		  
		  </font>	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="1%">&nbsp;</td>
      <td width="13%">College </td>
      <td colspan="3"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td>Course</td>
      <td colspan="3"><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td>Major</td>
      <td colspan="3"><select name="major_index">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td>Year Level</td>
      <td colspan="3"><select name="year_level">
          <option value="">All</option>
          <%
strTemp =WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
    </tr>
    <tr id="row_3"> 
      <td height="25"></td>
      <td></td>
      <td>Student ID </td>
      <td width="19%"><input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td colspan="2"><a href="javascript:ShowResult();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    
    <tr> 
      <td height="25"></td>
      <td colspan="2"></td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>

<%
int iCount = 0;
if(vRetResult != null && vRetResult.size() > 0) {
boolean bolShowProcessed = false;
if(WI.fillTextValue("show_processed").length() > 0 || WI.fillTextValue("show_zero_discount").length() > 0) 
	bolShowProcessed = true;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td style="font-size:11px; font-weight:bold; color:#0000FF"> Note: Set to 0 amount to remove cash discount OR set to any new amount</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4" bgcolor="#C2BEA3"><div align="center"><strong>::: CASH DISCOUNT DETAIL - ORIGINAL:::</strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#cccccc" style="font-weight:bold"> 
      <td height="25" width="3%" class="thinborder">Count</td>
      <td width="10%" class="thinborder">Student ID </td>
      <td width="17%" class="thinborder">Student Name </td>
      <td width="10%" class="thinborder">Course-Year</td>
      <td width="10%" class="thinborder">Total Assessment </td>
      <td width="5%" class="thinborder">Prev Balance </td>
      <td width="10%" class="thinborder">Total Payment </td>
      <td width="5%" class="thinborder">Unpaid  Balance</td>
      <td width="5%" class="thinborder">Original Discount  </td>
<%if(bolShowProcessed){%>
      <td width="5%" class="thinborder">Current Discount </td>
      <td width="5%" class="thinborder">Update Reason </td>
<%}%>
      <td width="5%" class="thinborder">New Discount </td>
      <td width="10%" class="thinborder">Reason</td>
      <td width="5%" class="thinborder">Update</td>
    </tr>
	<%for(int i = 0; i < vRetResult.size() ; i += 13) {%>
		<tr>
		  <td height="25" class="thinborder"><%=iCount + 1%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"-","","")%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 9)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 10)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 6)%>
		  <input type="hidden" name="orig_amt_<%=iCount%>" value="<%=vRetResult.elementAt(i + 6)%>">		  </td>
<%if(bolShowProcessed){%>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 11)%></td>
          <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 12), "&nbsp;")%></td>
<%}%>
		  <td class="thinborder"><input type="text" class="textbox" name="new_amt_<%=iCount%>" size="7" align="right"></td>
		  <td class="thinborder"><input type="text" class="textbox" name="reason_<%=iCount%>" size="15" align="right" style="font-size:11px;"></td>
		  <td class="thinborder"><input type="checkbox" name="new_amt_update_<%=iCount++%>" value="<%=vRetResult.elementAt(i)%>"></td>
		</tr>
	<%}%>
	<input type="hidden" name="max_count_up" value="<%=iCount%>">
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center">
	  <input type="submit" name="12" value="&nbsp;&nbsp;Update Information&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
	  </td>
    </tr>
  </table>
<%}//end if vRetResult is not null%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="reloadPage">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>