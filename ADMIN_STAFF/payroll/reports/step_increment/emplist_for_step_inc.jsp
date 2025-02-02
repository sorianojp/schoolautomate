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
<title>Employee eligible for increment</title>
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
	location = "emplist_for_step_inc.jsp";	
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
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="emplist_for_step_inc.jsp">

<%  WebInterface WI = new WebInterface(request);


	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./emplist_for_step_inc_print.jsp" />
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
								"Admin/staff-Payroll-Reports-Step Increment-Eligible List","emplist_for_step_inc.jsp");
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
	if(strPageAction.length() > 0){
	  if(RptPay.operateOnEmpSalGradeStep(dbOP,Integer.parseInt(strPageAction))== null){
		strErrMsg = RptPay.getErrMsg();
	  }else{
		strErrMsg = "Operation Successful";
	  }
	}

	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = RptPay.getEmplistStepInc(dbOP);
		if(vRetResult == null)
		  strErrMsg = RptPay.getErrMsg();
		else
		  iSearchResult = RptPay.getSearchCount();
	}
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="23" colspan="3" align="center" class="footerDynamic">        
				<font color="#FFFFFF" ><strong>:::: 
          PAYROLL : EMPLOYEE LIST ELIGIBLE FOR STEP INCREMENT PAGE ::::</strong></font>      </td>
    </tr>
    
    <tr> 
      <td width="100%" height="23" colspan="3"><strong><font size="1"><a href="./step_inc_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Step</td>
	  <%
	  	strTemp = WI.fillTextValue("step");
	  %>
      <td colspan="3">
        <select name="step" onChange="ReloadPage();">
          <%for(i = 2; i < 11;i++){%>
          <%if(strTemp.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected>Step <%=i%></option>
          <%}else{%>
          <option value="<%=i%>">Step <%=i%></option>
          <%}%>
          <%}%>
        </select>
	  </td>
    </tr>    	
    <tr>
      <td height="24">&nbsp;</td>
      <td>Date Increment </td>
	  <%
	  	strTemp = WI.fillTextValue("increment_date");
	  %>	  
      <td colspan="3"><input name="increment_date" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.increment_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" alt="Click to set " border="0"></a></td>
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
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> <select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :<strong></strong></td>
      <td height="29"> <select name="sort_by1">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a><font size="1">click 
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
<%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr>
      <td><div align="right"><font size="2"> Number of Employees Per Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =2; i <=45 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
      <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></div></td>
    </tr>
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
      <td  width="8%" height="25" align="center" ><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="25%" align="center"><strong><font size="1">NAME</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">EMPLOYMENT STATUS</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">DOE</font></strong></td>
      <td width="15%" align="center"><strong><font size="1">SALARY GRADE </font></strong></td>
      <td width="19%" align="center"><strong><font size="1">LENGTH OF SERVICE </font></strong></td>
	  <td width="17%" align="center"><strong><font size="1">OPTION</font></strong></td>
	  <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% int iCount = 0;
	   int iMax = 1;
	for(i = 0 ; i < vRetResult.size(); i +=13,iCount++,iMax++){%>
    <tr> 
      <td height="25">&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td height="25"><font size="1"><%=WI.formatName(((String)vRetResult.elementAt(i+2)).toUpperCase(), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)).toUpperCase(), 4)%></font></td>
      <%
	  	if(vRetResult.elementAt(i + 8) != null){
			strTemp = (String) vRetResult.elementAt(i + 8);
			strTemp = astrPTFT[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}
	  %>
      <td>&nbsp;<font size="1"><%=WI.getStrValue(strTemp,"No Service Record")%></font></td>
      <td>&nbsp;<font size="1"><%=(String) vRetResult.elementAt(i + 7)%></font></td>

      <td>
	  <%
	  strTemp = (String) vRetResult.elementAt(i + 10);
	  if(((String)vRetResult.elementAt(i+11)).equals("0")){%>
	  Sal Grade 
	  <input name="salary_grade<%=i%>" type="text" class="textbox_noborder" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="3" 
	  maxlength="3" readonly style="text-align:right">	  
	  <%}else{%>
	  <select name="salary_grade<%=i%>" style="font-size:11px">
        <% for(int iSalGrade = 1;iSalGrade < 41;iSalGrade++){
		if(strTemp.equals(Integer.toString(iSalGrade))){%>
        <option value="<%=iSalGrade%>" selected>Sal Grade <%=iSalGrade%></option>
        <%}else{%>
        <option value="<%=iSalGrade%>">Sal Grade <%=iSalGrade%></option>
        <%}%>
        <%}%>
      </select>
	  <%}%>	  </td>
      <%
	  	if(vRetResult.elementAt(i + 9) != null){
			strTemp = (String) vRetResult.elementAt(i + 9);
		}else{
			strTemp = "";
		}
	  %>
      <td>&nbsp;<font size="1"><%=WI.getStrValue(strTemp,"No Service Record")%></font></td>
	  <td>
	  	<%if(((String)vRetResult.elementAt(i+11)).equals("0")){%>
		  <a href="javascript:VerifyRecord('<%=(String)vRetResult.elementAt(i+12)%>','<%=(String)vRetResult.elementAt(i)%>','salary_grade<%=i%>')"><img src="../../../../images/verify.gif" width="54" height="20" border="0"></a>
		  <a href="javascript:CancelSave('<%=(String)vRetResult.elementAt(i+12)%>')"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a>
		<%}else{%>
		  <a href="javascript:SaveOne('<%=(String)vRetResult.elementAt(i)%>','salary_grade<%=i%>' )"><img src="../../../../images/save.gif" width="48" height="28" border="0"></a>		
	  	<%}%>	  </td>
	  <!--
      <td> <div align="center">
          <input type="checkbox" name="user_<%=iCount%>" value="1">
          <input type="hidden" name="user_index_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
        </div></td>
	  -->
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