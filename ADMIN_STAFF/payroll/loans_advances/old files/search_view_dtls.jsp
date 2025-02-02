<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRLoansAdv" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<style type="text/css">
<!--
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
	font-size: 12px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
.clearColor{ background-color : #FFFFFF}
}
-->
</style>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="post_ded_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS/ADVANCES-search Entries","search_view_dtls.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","LOANS/ADVANCES",request.getRemoteAddr(),
														"search_view_dtls.jsp");
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
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vInfoDetail = null;

PRLoansAdv prd = new PRLoansAdv(request);

String[]  astrSchedDeduct={
	"Every Salary Period", "Every 5th of Month", "Every 15th of Month", "Every 20th of Month",
"Every end of Month", "Every Week", "End of Term"};


if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}
}
%>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.payable.value = strPayable;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./loans_advances_entry.jsp?emp_id="+document.form_.emp_id.value;
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function ComputeDue(){
	
	if (document.form_.terms.value.length > 0){
		if (eval(document.form_.terms.value) !=0){
			document.form_.due.value = eval(document.form_.amount.value)/eval(document.form_.terms.value);
			document.form_.due.value = truncateFloat(document.form_.due.value,1,false);
		}
	 }else{
		 document.form_.due.value ="0";
	 }
	
}

function PrintPg(){

	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";
	document.bgColor = "#FFFFFF";
	document.getElementById('myTable1').deleteRow(0);
	document.getElementById('myTable1').deleteRow(0);
		
	document.getElementById("myADTable").getElementsByTagName("tr")[0].style.backgroundColor ="#FFFFFF";
	this.insRow(0, 1, strInfo);
	this.insRow(1, 1, "&nbsp");
	this.insRow(2, 1, "<hr size=1>");
	
	
	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);
	
	window.print();
}

-->
</script>


<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./loans_advances_entry.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr  bgcolor="#C0B998"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: LOANS/ADVANCES ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable1">
    <tr> 
      <td height="23"><strong>&nbsp;&nbsp;<a href="search_entry.jsp"><img src="../../../images/go_back.gif" border="0" ></a><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>

<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>

	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
    <tr> 
      <td height="10" colspan="2"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="6%" height="22">&nbsp;</td>
      <td height="22">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="22"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>

    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td width="94%">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>

    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if(vInfoDetail != null)  strTemp=(String)vInfoDetail.elementAt(15);
  vRetResult = prd.operateOnLoansAdv(dbOP,request,4);
	if (vRetResult != null) {%>
  <table cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="28" colspan="4" class="thinborder"><strong>TOTAL APPLIED <br>
        ADVANCES/DEDUCTIONS : <font color="#0000FF"><%=(String)vRetResult.elementAt(0)%></font></strong></td>
      <td height="28" colspan="4" class="thinborder"><strong>TOTAL ACTIVE <br>
        ADVANCES/DEDUCTIONS : <font color="#FF9900"><%=(String)vRetResult.elementAt(1)%></font></strong></td>
      <td height="28" colspan="2" class="thinborder"><strong>CURRENT BALANCE : 
        <br>
        <font color="#FF0000">Php <%=CommonUtil.formatFloat((String)vRetResult.elementAt(2),true)%></font></strong></td>
    </tr>
    <tr> 
      <td width="9%" height="28" class="thinborder"><div align="center"><font size="1"><strong>DATE 
          APPLIED</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>APPLICATION 
          NO.</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION 
          </strong> </font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT 
          APPLIED</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>DATE 
          APPROVED</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>TERMS 
          </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE 
          OF DEDUCTION</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>START 
          OF DEDUCTION</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>DUE 
          PER DEDUCTION</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>BALANCE</strong></font></div></td>
    </tr>
    <% for (int i = 3; i < vRetResult.size() ; i+=18){ 

	%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+6)%></div></td>
      <td height="25" class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+8)%></div></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp")%></td>
      <td class="thinborder"><div align="center">
	  <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+7)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+10)%></div></td>
      <td class="thinborder"><div align="center"><%=astrSchedDeduct[Integer.parseInt((String)vRetResult.elementAt(i+11))]%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+12)%></div></td>
      <td class="thinborder"><div align="center">
	  <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+13),true)%></div></td>
      <td class="thinborder"><div align="center">
	  <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true)%></div></td>
    </tr>
    <%}%>
  </table>
<%}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myTable3">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="center"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print page</font></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>