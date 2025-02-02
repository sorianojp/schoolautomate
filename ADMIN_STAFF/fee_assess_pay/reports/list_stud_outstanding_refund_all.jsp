<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";//strSchCode = "UC";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
var imgWnd;
function PrintPg()
{
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
<%if(!strSchCode.startsWith("FATIMA")){%>
	document.getElementById('myADTable2').deleteRow(0);
<%}%>
<%if(strSchCode.startsWith("EAC")){%>
	document.getElementById('myADTable2').deleteRow(0);
<%}%>

	document.getElementById('myADTable2').deleteRow(0);
	window.print();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}

</script>
<body bgcolor="#ffffff" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedgerExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_outstanding_refund_all.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"list_stud_outstanding_refund_all.jsp");
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
Vector vRetResult  = null;
FAStudentLedgerExtn studLedg = new FAStudentLedgerExtn();
if(WI.fillTextValue("date_fr").length() > 0 && WI.fillTextValue("donot_show").length() == 0) {
	vRetResult = studLedg.viewOutStandingBalanceAndRefundOfALL(dbOP, request);
	if(vRetResult == null)
		strErrMsg = studLedg.getErrMsg();
}
//System.out.println(vRetResult);	

String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Year Level"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","stud_curriculum_hist.year_level"};
String[] astrConvertTerm   = {"Summer","1st Term","2nd Term","3rd Term"};

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;
	
%>
<form action="./list_stud_outstanding_refund_all.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STUDENTS WITH OUTSTANDING BALANCE/REFUND PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td width="1%" height="25"></td>
      <td colspan="4" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
<%if(!strSchCode.startsWith("FATIMA")){
	strTemp = WI.fillTextValue("is_basic");
	if(strTemp.length() > 0) 
		strTemp = " checked";
	%>
    <tr>
      <td height="25"></td>
      <td colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF">
			  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="document.form_.donot_show.value='1';document.form_.submit();"> Process Report for Grade School 
		  &nbsp;&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td height="25"></td>
      <td class="thinborderNONE">Cutoff date/Range</td>
      <td colspan="3"><font size="1">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  
      <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
<%if(strSchCode.startsWith("EAC")){%>
    <tr>
      <td height="25"></td>
      <td class="thinborderNONE">SY-Term (optional) </td>
      <td colspan="3" style="font-weight:bold; color:#0000FF; font-size:9px;">
	  	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  		onKeyUp='DisplaySYTo("fee_report","sy_from","sy_to")'> - 
			
	  
        <select name="semester">          
			<option value=""></option>
<%
strTemp = WI.fillTextValue("semester");
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
        </select> 
		
		&nbsp;&nbsp;
		<input type="checkbox" name="sort_by_sy_term" value="checked" <%=WI.fillTextValue("sort_by_sy_term")%>>
		Display per SY-Term
		
	  </td>
    </tr>
<%}if(!bolIsBasic) {%>
    <tr id="row_3">
      <td height="25"></td>
      <td class="thinborderNONE">College</td>
      <td colspan="3">
	  <select name="c_index">
		<option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> 
		</select>	  </td>
    </tr>
<%}else{%>
    <tr id="row_3">
      <td height="25"></td>
      <td class="thinborderNONE">Grade Level</td>
      <td colspan="3">
	  <select name="edu_level">
		<option value="">All</option>
          <%=dbOP.loadCombo("distinct edu_level","edu_level_name"," from bed_level_info order by edu_level", request.getParameter("edu_level"), false)%> 
		</select>	  </td>
    </tr>
<%}%>
    <tr id="row_3"> 
      <td height="25"></td>
      <td width="16%" class="thinborderNONE">Student ID </td>
      <td width="18%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td colspan="2" class="thinborderNONE">&nbsp;</td>
    </tr>
    <tr id="row_2"> 
      <td height="25"></td>
      <td class="thinborderNONE">&nbsp;</td>
      <td width="18%">
        <input type="submit" name="12" value=" Generate list " style="font-size:11px; height:28px;border: 1px solid #FF0000;">      </td>
      <td width="27%">
	  <select name="rows_per_page">
	  	<option value="1000000">All in One Page</option>
		<option value="50">50</option>
<%
int iDefValue = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "0"));
for(int i =51; i < 75; ++i){		
	if(iDefValue == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>	  </td>
      <td width="37%" valign="bottom">
	  <%if(vRetResult != null){%>
	  	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" name="print_hide"></a> <font size="1">click to print list</font>
	  <%}%>	  </td>
    </tr>
  </table>
<%if(vRetResult != null){
String strDateTime = WI.getTodaysDateTime();
if(WI.fillTextValue("is_basic").length() > 0)
	astrConvertTerm[1] = "Regular";

int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "1000000"));
int iPageNo = 0; 
int iCurRow = 0;
int iCount = 0;

String strSYFromInLoop = null;
String strSemInLoop    = null;
double dSubTotal       = 0d;
boolean bolGrpBySyTerm = false;
if(WI.fillTextValue("sort_by_sy_term").length() > 0) 
	bolGrpBySyTerm = true;


for(int i = 1; i < vRetResult.size();){
	if(strSYFromInLoop == null) {
		strSYFromInLoop = (String)vRetResult.elementAt(i + 6);
		strSemInLoop    = (String)vRetResult.elementAt(i + 7);
	}
iCurRow =0;

if(i > 1){%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="2" align="center"><u><strong> LIST OF STUDENT WITH OUTSTANDING BALANCE</strong></u></td>
    </tr>
    <tr> 
      <td style="font-size:9px;" width="50%" valign="bottom">Page #: <%=++iPageNo%></td>
      <td align="right" style="font-size:9px;" valign="bottom">Date Time Printed: <%=strDateTime%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold">
      <td width="5%" class="thinborder" style="font-size:9px;">No.</td> 
      <td width="15%" height="24" class="thinborder" style="font-size:9px;">Student ID</td>
      <td width="33%" class="thinborder" style="font-size:9px;">Student Name</td>
      <td width="19%" class="thinborder" style="font-size:9px;"><%if(bolIsBasic){%>Grade Level<%}else{%>Course-Yr<%}%></td>
      <td width="14%" class="thinborder" style="font-size:9px;">Last SY/Term </td>
      <td width="14%" class="thinborder" style="font-size:9px;"> Balance</td>
    </tr>
<%
for(; i < vRetResult.size(); i += 9) {
if(++iCurRow > iRowsPerPage)
	break;

if(bolGrpBySyTerm) {
	if(!strSYFromInLoop.equals(vRetResult.elementAt(i + 6)) || !strSemInLoop.equals(vRetResult.elementAt(i + 7)) ){
			strSYFromInLoop = (String)vRetResult.elementAt(i + 6);
			strSemInLoop    = (String)vRetResult.elementAt(i + 7);
			++iCurRow;
	%>
		<tr>
		  <td height="20" colspan="6" class="thinborder" style="font-size:10px; font-weight:bold" align="right">Sub Total: <%=CommonUtil.formatFloat(dSubTotal, true)%> </td>
		</tr>
	<%dSubTotal = 0d;}
	dSubTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 8), ",",""));
}
%>
    <tr>
      <td class="thinborder" style="font-size:10px;"><%=++iCount%></td>
      <td height="20" class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:10px;">
	  	<%if(bolIsBasic){%>
			<%=vRetResult.elementAt(i + 3)%>
		<%}else{%>
			<%=vRetResult.elementAt(i + 3)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "-","","")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "-","","")%>
		<%}%>      </td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 6)%> - 
	  	<%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(i + 7))]%>	  </td>
      <td class="thinborder" style="font-size:9px;" align="right"><%=vRetResult.elementAt(i + 8)%></td>
    </tr>
<%}
}

//show sub total.
if(bolGrpBySyTerm && dSubTotal > 0) {%>
		<tr>
		  <td height="20" colspan="6" class="thinborder" style="font-size:10px; font-weight:bold" align="right">Sub Total: <%=CommonUtil.formatFloat(dSubTotal, true)%> </td>
		</tr>
	<%dSubTotal = 0d;
}
%>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="24" align="right"><strong><font size="1">TOTAL :<%=vRetResult.remove(0)%></font></strong><strong></strong></td>
    </tr>
  </table>
 <%}//only if vRetResult != null%>
<input type="hidden" name="donot_show">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>