<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-misc fee","print_misc_fee_per_fee_name.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"print_misc_fee_per_fee_name.jsp");
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

ReportFeeAssessment RFA = new ReportFeeAssessment();
Vector vRetResult = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(WI.fillTextValue("show_report").length() > 0 && WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = RFA.getDisctinctMiscFee(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}

int iDefVal=0;


String strSYFrom = null;
strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");


boolean bolIsSWU = strSchCode.startsWith("SWU");
%> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.textbox_noborder2{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
		border:none;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.show_report.value='';
	document.form_.submit();
}
function ShowReport() {
	document.form_.show_report.value='1';
	document.form_.submit();	
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}

function SetFocusIndex(strIndex){
	document.form_.focus_index.value = strIndex;
}
function ViewCourseWithFee(strCatgIndex, strFeeName) {
	var loadPg = "./print_oth_charge_per_subj_fee_del.jsp?syf="+document.form_.sy_from.value+
				"&catg="+strCatgIndex+"&fee="+escape(strFeeName);
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateFee(strFeeName, strOldAmt, strLabel, strDelete) {
	<%if(iAccessLevel ==1) {%>
		return;
	<%}%>
	
	strNewAmt = '';
	if(strDelete.length == 0) {
		strNewAmt = prompt('Please enter new amount.');
		if(strNewAmt == null || strNewAmt.length == 0) {
			alert("Request cancelled.");
			return;
		}
	}
	else {
		if(!confirm('Are you sure you want to delete fee in batch.'))
			return;
		strNewAmt = '0';
	}
	objAmount = document.getElementById(strLabel);
	
	this.InitXmlHttpObject(objAmount, 2);//I want to get value in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=99&fee_="+escape(strFeeName)+
				"&new_amt="+strNewAmt+"&sy_f="+document.form_.sy_from.value+"&sem_="+
				document.form_.semester[document.form_.semester.selectedIndex].value+
				"&old_amt="+strOldAmt;
	if(document.form_.c_index.selectedIndex > 0) 
		strURL +="&c_index="+document.form_.c_index[document.form_.c_index.selectedIndex].value;
	if(document.form_.course_index.selectedIndex > 0) 
		strURL +="&course_index="+document.form_.course_index[document.form_.course_index.selectedIndex].value;
	if(strDelete.length > 0) 
		strURL +="&is_del_=1";
		
	if(document.form_.id_sy_range) 
		strURL += "&id_range="+document.form_.id_sy_range[document.form_.id_sy_range.selectedIndex].value;
		
	 //alert(strURL);
	
	this.processRequest(strURL);
}
</script>

<body bgcolor="#D2AE72">
<form name="form_" action="./print_misc_fee_per_fee_name.jsp" method="post">
<input type="hidden" name="focus_index" value="<%=WI.fillTextValue("focus_index")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: DISPLAY/PRINT PER MISCELLANEOUS FEE  ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="22" colspan="4">&nbsp;&nbsp;<b><font size="3"><%=strErrMsg%></font></b></td>
    </tr>
 <%
if(strSchCode.startsWith("CIT") && !WI.fillTextValue("oth_charge").equals("1")) {%>
    <tr style="font-weight:bold; color:#0000FF;">
      <td height="25">&nbsp;</td>
      <td colspan="4">Applicable SY Range<font style="font-weight:bold; color:#FF0000">*</font> :
	  <select name="id_sy_range" onChange="ReloadPage();">
          <%=dbOP.loadCombo("ID_RANGE_INDEX","RANGE_SY_FROM,RANGE_SY_TO"," from FA_CIT_IDRANGE where IS_ACTIVE_RECORD=1 and eff_fr_sy = "+strSYFrom+" order by RANGE_SY_FROM asc", WI.fillTextValue("id_sy_range"), false)%> 
	  </select>
<strong><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click 
        to refresh page</font></strong>	  </td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="22">&nbsp;</td>
      <td width="9%">SY/Term </td>
      <td width="39%">
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || evesdflsjnt.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
   <%
	strTemp = request.getParameter("sy_to");
	if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
<%
strTemp = WI.fillTextValue("semester");
if(request.getParameter("semester") == null) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");	

if(strTemp == null)
	strTemp = "";
%>
	  <select name="semester">
	  <option value="">Show for ALL Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>	  </td>
      <td width="50%"><a href="javascript:ShowReport();"><img src="../../../images/view.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
	  <select name="c_index" onChange="ReloadPage();" style="font-size:14px;background:#DFDBD2; width:400;">
          <option></option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_del=0 order by c_name asc", WI.fillTextValue("c_index"), false)%> 
        </select>
	  </td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">
<%
strErrMsg = WI.fillTextValue("c_index");
if(strErrMsg.length() > 0) 
	strErrMsg = " and c_index = "+strErrMsg;
%>
		<select name="course_index" onChange="ReloadPage();" style="font-size:14px;background:#DFDBD2; width:700;">
          <option value=""></option>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname"," from course_offered where IS_DEL=0 AND IS_VALID=1"+strErrMsg+" order by cname asc", WI.fillTextValue("course_index"), false)%> 
        </select>
	  </td>
    </tr>
<!--
    <tr>
      <td height="22">&nbsp;</td>
      <td>Course </td>
      <td colspan="2">
  <%
	strTemp = request.getParameter("course_index");
	if(strTemp == null || strTemp.compareTo("selany") == 0) strTemp = "";
	%> <select name="course_index" onChange="ReloadPage();">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", strTemp, false)%> </select> </td>
    </tr>
-->    
	

    <tr>
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" align="right">
        <% if(vRetResult != null && vRetResult.size() > 0) {%>
		<select name="rows_per_page">
		<%
		iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "40"));
		for(int i = 35; i < 70; ++i) {
			if(i == iDefVal)
				strTemp = " selected";
			else	
				strTemp = "";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
		</select>
		
		
		
        <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">
        Print page.</font>&nbsp;&nbsp;&nbsp;&nbsp;
        <%}%>      </td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0) {
	String[] convertYearLevel = {"ALL","1ST YEAR","2ND YEAR","3RD YEAR","4TH YEAR","5TH YEAR","6TH YEAR","7TH YEAR","8TH YEAR"};
	String[] strConvertSem    = {"SUMMER","1ST","2ND","3RD","4TH","ALL"};
	String[] astrConvertToFeeType = {"Per Unit","Per Type","Per Hour","Amt*UE"};

int iRowCount = 1;
//System.out.println(vRetResult);
for (int i = 0; i < vRetResult.size();) {
	iRowCount = 1;
	if(i > 0) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
    <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DDDDDD">
      <td height="22" colspan="11" class="thinborder"><div align="center"><strong><font size="1">
	  LIST OF MISC FEE </font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="20%" height="22" class="thinborder"><font size="1">Fee Name</font></td>
      <td width="10%" class="thinborder"><font size="1">Amount</font></td>
      <td width="7%" class="thinborder"><font size="1">Semester</font></td>
      <td width="6%" class="thinborder">View Courses with Fee </td>
<%if(bolIsSWU){%>
      <td width="6%" class="thinborder">Delete Fee </td>
<%}%>
    </tr>
    <%
for(; i< vRetResult.size() ; i+=4, ++iRowCount) {
if(iRowCount >iDefVal)
	break;
%>
    <tr>
      <td height="22" class="thinborder" onDblClick='UpdateFee("<%=vRetResult.elementAt(i)%>","<%=vRetResult.elementAt(i + 1)%>","_<%=i%>","");'><%=vRetResult.elementAt(i)%></td>
      <td align="right" class="thinborder" onDblClick='UpdateFee("<%=vRetResult.elementAt(i)%>","<%=vRetResult.elementAt(i + 1)%>","_<%=i%>","");'><label id="_<%=i%>"><%=vRetResult.elementAt(i + 2)%></label></td>
      <td align="center" class="thinborder" onDblClick='UpdateFee("<%=vRetResult.elementAt(i)%>","<%=vRetResult.elementAt(i + 1)%>","_<%=i%>","");'><%=strConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 3), "5"))]%></td>
      <td align="center" class="thinborder" onDblClick='UpdateFee("<%=vRetResult.elementAt(i)%>","<%=vRetResult.elementAt(i + 1)%>","_<%=i%>","");'><a href='javascript:ViewCourseWithFee("<%=vRetResult.elementAt(i)%>","<%=vRetResult.elementAt(i + 1)%>");'>View</a>&nbsp;</td>
<%if(bolIsSWU){%>
      <td align="center" class="thinborder">
	  <%if(iAccessLevel == 2) {%>
		  	<a href='javascript:UpdateFee("<%=vRetResult.elementAt(i)%>","<%=vRetResult.elementAt(i + 1)%>","_<%=i%>","1");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}%>
	  </td>
<%}%>
    </tr>
<%
	}//end of displaying levels
%>
  </table>
<%}//outer for loop
}//if condition
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="show_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
