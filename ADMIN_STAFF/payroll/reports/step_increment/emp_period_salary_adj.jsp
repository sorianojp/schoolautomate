<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
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
<title>Increment Lists</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.noBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	
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
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function CancelRecord(){
	location = "emp_period_step_inc.jsp";	
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function CancelSave(strIndex){
	document.form_.print_page.value="";
	document.form_.emplist_index.value = strIndex;
	document.form_.searchEmployee.value = "1";
	document.form_.page_action.value= "0";		
	this.SubmitOnce("form_");
}
function VerifyRecord(strIndex, strEmpIndex, strSalGrade){
	document.form_.print_page.value="";
	document.form_.emplist_index.value = strIndex;
	document.form_.emp_index.value=strEmpIndex;
	document.form_.sal_grade.value=strSalGrade;
	document.form_.searchEmployee.value = "1";
	document.form_.page_action.value= "5";		
	this.SubmitOnce("form_");
}
function SaveOne(strEmpIndex, strSalGrade){
	document.form_.searchEmployee.value = "1";
	document.form_.emp_index.value=strEmpIndex;
	document.form_.sal_grade.value=strSalGrade;
	document.form_.page_action.value= "1";		
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function ViewPrintDetails(strIncIndex, strEmpID, strEmpType){
	var pgLoc = "./step_inc_details.jsp?inc_index="+strIncIndex+"&emp_id="+strEmpID+
							"&emp_type="+strEmpType+
							"&month_of="+document.form_.month_of.value+
							"&year_of="+document.form_.year_of.value;
	var win=window.open(pgLoc,"PrintWindow",'width=650,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="emp_period_step_inc.jsp">
<%  
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./emp_period_step_inc_print.jsp" />
	<%return;}
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Step Increment-Increment for Period","emp_period_step_inc.jsp");
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
//end of authenticaion code.

	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String[] astrPTFT = {"Part-Time", "Full-time"};
	String[] astrSortByName = {"Employee ID","Firstname","Lastname", "Date of Employment"};
	String[] astrSortByVal  = {"id_number","fname","lname", "doe"};
	String strPageAction = WI.fillTextValue("page_action");

	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = RptPay.getPeriodStepIncrements(dbOP);
		if(vRetResult == null)
		  strErrMsg = RptPay.getErrMsg();
		else
		  iSearchResult = RptPay.getSearchCount();
	}
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="23" colspan="3" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : EMPLOYEES WITH SALARY ADJUSTMENT FOR PERIOD ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="100%" height="23" colspan="3"><strong><font size="1"><a href="./step_inc_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
	  <%
	  	strTemp = WI.fillTextValue("step");
	  %>
      <td colspan="3"><select name="month_of">
        <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
      </select>
-
<select name="year_of">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),4,1)%>
</select></td>
    </tr>    	
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select>
	  </td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Position</td>
      <td colspan="3"><select name="emp_type_index">
        <option value="" selected>ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index">
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label>
			</td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a><font size="1"> click 
        to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">LIST 
      OF EMPLOYEES</font></strong></td>
    </tr>
    <tr>
      <td><div align="right"><font size="2"> Number of Employees Per Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =10; i <=25 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
      <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></div></td>
    </tr>
	<%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>		
    <tr> 
      <td><div align="right"><font size="2">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          </font></div></td>
    </tr>
	<%}%>	
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="13%" height="25" align="center" ><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="43%" align="center"><strong><font size="1">NAME</font></strong></td>
      <td width="15%" align="center"><strong><font size="1">POSITION</font></strong></td>
      <td width="16%" align="center"><strong><font size="1">INCREMENT DATE </font></strong></td>
      <td width="13%" align="center"><strong><font size="1">NEW RATE</font></strong></td>
	    <td width="13%" align="center"><strong><font size="1">NOTICE</font></strong></td>
	    <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% int iCount = 0;
	   int iMax = 1;
	for(i = 0 ; i < vRetResult.size(); i +=26,iCount++,iMax++){%>
    <tr> 
      <td height="25">&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td height="25"><font size="1">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 9)%></font></td>
      <td align="right"><font size="1"><%=(String)vRetResult.elementAt(i + 11)%>&nbsp;</font></td>
      <td align="right"><font size="1"><%=(String)vRetResult.elementAt(i + 10)%>&nbsp;</font></td>
      <td align="center"><a href="javascript:ViewPrintDetails('<%=vRetResult.elementAt(i + 16)%>', '<%=vRetResult.elementAt(i + 3)%>', '<%=vRetResult.elementAt(i + 17)%>');"><strong><font size="1">DETAILS</font></strong></a></td>
    </tr>
    <%}//end of for loop to display employee information.%>
	<input type="hidden" name="max_display" value="<%=iMax%>">
  </table>  
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
  <input type="hidden" name="page_action">
  <input type="hidden" name="sal_grade">
  <input type="hidden" name="emp_index">
  <input type="hidden" name="emplist_index">
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>