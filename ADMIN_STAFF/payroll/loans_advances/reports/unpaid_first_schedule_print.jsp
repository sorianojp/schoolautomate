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
<title>Period Loans Reconciliation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

function loadSalPeriods() {
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	var strWeekly = null;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2  = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Reports-Period Loans Reconciliation","unpaid_first_schedule.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");	
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");		
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
														"PAYROLL","LOANS/ADVANCES",request.getRemoteAddr(),
														"unpaid_first_schedule.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


PReDTRME prEdtrME = new PReDTRME();
Vector vRetResult = null;
PRRetirementLoan RptPay = new PRRetirementLoan(request);
int i = 0;
String[] astrSortByName    = {"Employee ID","Last name", "Firstname","Loan Code"};
String[] astrSortByVal     = {"id_number","user_table.lname", "user_table.fname","loan_code"};
boolean bolPageBreak  = false;
  vRetResult = RptPay.getFirstSchedWithoutPayment(dbOP);
	if (vRetResult != null) {			
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(20*iMaxRecPerPage);	
	if((vRetResult.size() % (20*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){	
%>
<body>
<form name="form_" >
   <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr > 
      <td height="23" colspan="6" align="center" class="thinborder"><strong>LOANS WITH FIRST PAYMENT DUE as of <%=WI.getTodaysDateTime()%></strong></td>
    </tr>
    <tr> 
      <td width="4%" height="27" align="center" class="thinborder">&nbsp;</td>
      <td width="36%" align="center" class="thinborder"><strong>EMPLOYEE NAME</strong></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">LOAN 
      CODE </font></strong></td>
      <td width="14%" align="center" class="thinborder"><strong><font size="1">DATE SCHEDULE </font></strong></td>
      <td width="14%" align="center" class="thinborder"><strong><font size="1">SCHEDULE PAY</font></strong></td>
      <td width="14%" align="center" class="thinborder"><strong><font size="1">ACTUAL PAID</font></strong></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>		
		<tr>   
		  <%
				strTemp = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2),
								(String)vRetResult.elementAt(i+3), 4).toUpperCase();
		  %>		
		  <td height="25" class="thinborder">&nbsp;<%=iIncr%></td>
		  <td class="thinborder" >&nbsp;<font size="1">&nbsp;<%=strTemp%></font></td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+5);
			if(((String)vRetResult.elementAt(i+7)).equals("1"))
				strTemp2 = "int";
			else
				strTemp2 = "";
		  %>		  
		  <td class="thinborder" ><font size="1">&nbsp;<%=strTemp%> <%=WI.getStrValue(strTemp2,"(",")","")%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+7);
			%>
		  <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+8);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		  %>
		  <td align="right" class="thinborder"><font size="1"><%=strTemp%></font>&nbsp;</td>
		  <%
		  	strTemp = (String)vRetResult.elementAt(i+10);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		  %>
		  <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
    </tr>		
     <%} // end for loop	%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>