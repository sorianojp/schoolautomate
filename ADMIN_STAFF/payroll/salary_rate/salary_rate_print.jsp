<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Rate Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
//called for add or edit.
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0 ){
		document.form_.info_index.value = strInfoIndex;
	}
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddAddlRes() {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	var pgLoc = "./salary_rate_addl.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg() {
	if(document.form_.emp_id.value.length == 0) {
		alert("Please enter employee ID.");
		return;
	}
	
	var pgLoc = "./salary_rate_print.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}	

function FocusID() {
	document.form_.emp_id.focus();
}

function ComputeRates(){
	
	if (document.form_.basic_salary.value.length > 0){
		if (eval(document.form_.basic_salary.value) !=0){
			document.form_.daily_sal.value = eval(document.form_.basic_salary.value)/30;
			document.form_.daily_sal.value = truncateFloat(document.form_.daily_sal.value,1,false);
		}
	 }else{
		 document.form_.daily_sal.value ="0";
	 }

	if (document.form_.daily_sal.value.length > 0){
		if (eval(document.form_.daily_sal.value) !=0){
			document.form_.hourly_sal.value = eval(document.form_.daily_sal.value)/8;
			document.form_.hourly_sal.value = truncateFloat(document.form_.hourly_sal.value,1,false);
		}
	 }else{
		 document.form_.hourly_sal.value ="0";
	 }	 

}
</script>
<%@ page language="java" import="utility.*,payroll.PRSalaryRate,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - Tax Status","salary_rate_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY_RATE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY_RATE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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
								"Admin/staff-Payroll - DTR-Absences","dtr_manual.jsp");
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

/**CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","SALARY_RATE",request.getRemoteAddr(),
														"salary_rate.jsp");
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
**/

//end of authenticaion code.

	PRSalaryRate prSalRate = new PRSalaryRate();
	Vector vRetResult = null; 
	Vector vEmpRec    = null;
	Vector vTaxStat   = null;
	Vector vEditInfo  = null;

strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prSalRate.operateOnSalaryMain(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prSalRate.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.equals("1"))
				strErrMsg = "Salary Rate Information successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Salary Rate Information successfully edited.";
			if(strTemp.equals("0"))
				strErrMsg = "Salary Rate Information successfully removed.";
		}//System.out.println(strErrMsg);
	}

if(WI.fillTextValue("emp_id").length() > 0) {
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null)
		strErrMsg = "Employee has no profile.";
}
if(vEmpRec != null && vEmpRec.size() > 0) {
	if(strPrepareToEdit.equals("1")) 
		vEditInfo = prSalRate.operateOnSalaryMain(dbOP, request, 3);
		
	vRetResult = prSalRate.operateOnSalaryMain(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = prSalRate.getErrMsg();
	
	vTaxStat = 	new payroll.PRTaxStatus().operateOnTaxStatus(dbOP, request,4);	
}

String[] astrConvertCivilStat = {"","Single","Married","Divorced/Separated","Widow/Widower"};
String[] astrConvertTaxStat   = {"Z (No Exemption)","Single","Head of Family","Married Employed"};
String[] astrConvertUnit = {"Per hr","Per unit","Per session"};
String[] astrConvertSalPeriod = {"Daily","Weekly","Bi-monthly","Monthly"};
%>
<body bgcolor="#FFFFFF">
<form action="./salary_rate_print.jsp" name="form_">
  <table  width="40%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="10%" height="25"><font size="1">Employee ID</font></td>
      <td width="90%"><font size="1"><%=WI.fillTextValue("emp_id")%></font></td>
    </tr>
  </table>
  
<%if(vEmpRec != null && vEmpRec.size() > 0) {%>
  <table width="40%" border="0" cellspacing="0" cellpadding="0" >
    <tr> 
      <td width="50%" height="18"> <%=WI.getStrValue(strTemp)%> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br>
        <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
        <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font></td>
    </tr>
    <tr> 
      <td height="18"><hr size="1"></td>
    </tr>
  </table>
 
<table width="40%" border="0" align="left" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="18" colspan="2"><div align="center"></div></td>
    </tr>
    <tr> 
      <td width="7%" height="26" class="thinborder"><div align="left"><strong><font size="1">INCLUSIVE 
          DATES</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><%=(String)vRetResult.elementAt(9)%> <%=WI.getStrValue((String)vRetResult.elementAt(10)," - <br>",""," - present")%></strong></div></td>
    </tr>
    <tr> 
      <td class="thinborder"><div align="left"><strong><font size="1">BASIC SALARY</font></strong></div></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(1)%>
    <tr> 
      <td class="thinborder"><div align="left"><strong><font size="1">DAILY RATE</font></strong></div></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(3),"","","&nbsp;")%></td>
    </tr>
    <tr> 
      <td class="thinborder"><div align="left"><strong><font size="1">HOURLY RATE</font></strong></div></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(4),"","","&nbsp;")%></td>
    </tr>
    <tr> 
      <td class="thinborder"><div align="left"><strong><font size="1">TEACH RATE</font></strong></div></td>
      <td align="center" class="thinborder"> <%if(vRetResult.elementAt(5) != null && ((String)vRetResult.elementAt(5)).compareTo("0.0") != 0){%> <%=(String)vRetResult.elementAt(5)%> <%=astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(6))]%> <%}else{%> &nbsp; <%}%> </td>
    </tr>
    <tr> 
      <td class="thinborder"><div align="left"><strong><font size="1">TEACH OVERLOAD 
          RATE</font></strong></div></td>
      <td align="center" class="thinborder"> <%if(vRetResult.elementAt(7) != null && ((String)vRetResult.elementAt(7)).compareTo("0.0") != 0){%> <%=(String)vRetResult.elementAt(7)%> <%=astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(8))]%> <%}else{%> &nbsp; <%}%> </td>
    </tr>
    <tr> 
      <td class="thinborder"><div align="left"><strong><font size="1">SAL PERIOD</font></strong></div></td>
      <td align="center" class="thinborder"><%=astrConvertSalPeriod[Integer.parseInt((String)vRetResult.elementAt(2))]%></td>
    </tr>
    <tr> 
      <td class="thinborder"><div align="left"><strong><font size="1">ACCOUNT 
          NUMBER</font></strong></div></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(12),"")%></td>
    </tr>
    <tr> 
      <td class="thinborder"><div align="left"><font size="1"><strong>ADDL JOB</strong></font></div></td>
      <td align="center" class="thinborder"> <%if((vRetResult.elementAt(13) == null || ((String)vRetResult.elementAt(13)).equals("0"))
		  	&& (vRetResult.elementAt(14) == null || ((String)vRetResult.elementAt(14)).equals("0"))
		   ) {%> <img src="../../../images/x.gif"> 
        <%}else{%>
        M <%=WI.getStrValue((String)vRetResult.elementAt(13))%> <br>
        BI <%=WI.getStrValue((String)vRetResult.elementAt(14))%> <%}%> </td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>