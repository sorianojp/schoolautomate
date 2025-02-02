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
function UpdateFee(strCatgIndex, strFeeName, strLabel) {
	strNewAmt = prompt('Please enter new amount.');
	if(strNewAmt == null || strNewAmt.length == 0) {
		alert("Request cancelled.");
		return;
	}
	objAmount = document.getElementById(strLabel);
	
	this.InitXmlHttpObject(objAmount, 2);//I want to get value in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=100&catg_="+strCatgIndex+"&fee_="+escape(strFeeName)+
				"&new_amt="+strNewAmt+"&sy_f="+document.form_.sy_from.value+"&sem_="+
				document.form_.semester[document.form_.semester.selectedIndex].value+
				"&is_oth_=1";
	this.processRequest(strURL);
}
</script>

<body bgcolor="#D2AE72">
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
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-misc fee","print_oth_charge_per_subj_fee.jsp");
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
														"print_oth_charge_per_subj_fee.jsp");
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

if(WI.fillTextValue("show_report").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && 
	WI.fillTextValue("semester").length() > 0) {
	vRetResult = RFA.getSubjectFeeWithCatg(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}

int iDefVal=0;
%>


<form name="form_" action="./print_oth_charge_per_subj_fee.jsp" method="post">
<input type="hidden" name="focus_index" value="<%=WI.fillTextValue("focus_index")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: FEE PER SUBJECT CATEGORY PRINT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="22" colspan="4">&nbsp;&nbsp;<b><font size="3"><%=strErrMsg%></font></b></td>
    </tr>
    <tr>
      <td width="2%" height="22">&nbsp;</td>
      <td width="9%">SY/Term </td>
      <td width="29%">
	<%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp == null || strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
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


if(strTemp.equals("0"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
	  <select name="semester">
	  <!--<option value="">Show ALL Semester</option>-->
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
      <td width="60%"><a href="javascript:ShowReport();"><img src="../../../images/view.gif" border="0"></a></td>
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
	<tr>
      <td height="22">&nbsp;</td>
      <td colspan="3">
<%
strTemp = WI.fillTextValue("show_offered");
if(strTemp.length() == 0) 
	strTemp = "1";
	
if(strTemp.equals("1"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>
	  <input type="radio" name="show_offered" value="1" <%=strErrMsg%>> Show Only Offered &nbsp;&nbsp;&nbsp;
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>
	  <input type="radio" name="show_offered" value="2" <%=strErrMsg%>> Show Only Offerd(with and without OC)
<%
if(strTemp.equals("0"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>
	  <input type="radio" name="show_offered" value="0" <%=strErrMsg%>> Show Only not Offered	  </td>
    </tr>

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
	String[] strConvertSem    = {"SUMMER","1ST","2ND","3RD","4TH","ALL", "&nbsp;"};
	String[] astrConvertToFeeType = {"Per Unit","Per Type","Per Hour","Amt*UE"};

int iRowCount = 1;

for (int i = 0; i < vRetResult.size();) {
	iRowCount = 1;
	if(i > 0) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
    <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DDDDDD">
      <td height="22" colspan="11" class="thinborder"><div align="center"><strong><font size="1">
	  LIST OF OTHER CHARGES (with Subject category)
	  <!--
	  FOR <%=WI.fillTextValue("sy_from") +" - "+WI.fillTextValue("sy_to")%><br>
          <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),(String)vRetResult.elementAt(i)+":::","",
		  (String)vRetResult.elementAt(i))%>--></b></font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="15%" height="22" class="thinborder"><strong><font size="1">Subject Code </font></strong></td>
      <td width="35%" class="thinborder"><font size="1">Subject Name </font></td>
      <td width="20%" class="thinborder"><font size="1">Subject Category </font></td>
      <td width="20%" class="thinborder"><font size="1">Fee Name</font></td>
      <td width="10%" class="thinborder"><font size="1">Amount</font></td>
      <td width="7%" class="thinborder"><font size="1">Charge Type </font></td>
      <td width="7%" class="thinborder"><font size="1">Semester</font></td>
      <td width="6%" class="thinborder"><font size="1">Year Level</font></td>
      <td width="6%" class="thinborder">View Courses with Fee </td>
    </tr>
<%
for(; i< vRetResult.size() ; i+=9, ++iRowCount) {
if(iRowCount >iDefVal)
	break;
if(vRetResult.elementAt(i + 8) != null) {%>
    <tr onDblClick='UpdateFee("<%=vRetResult.elementAt(i + 8)%>","<%=vRetResult.elementAt(i + 7)%>","_<%=i%>");'>
      <td height="22" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
      <td align="right" class="thinborder"><label id="_<%=i%>"><%=vRetResult.elementAt(i + 3)%></label></td>
      <td align="center" class="thinborder"><%=astrConvertToFeeType[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
      <td align="center" class="thinborder"><%=strConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 5), "5"))]%></td>
      <td align="center" class="thinborder"><%=convertYearLevel[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%></td>
      <td align="center" class="thinborder"><a href='javascript:ViewCourseWithFee("<%=vRetResult.elementAt(i + 8)%>","<%=vRetResult.elementAt(i + 7)%>");'>View</a></td>
    </tr>
<%}else{%>
    <tr>
      <td height="22" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><label id="_<%=i%>"></label></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
<%}
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
