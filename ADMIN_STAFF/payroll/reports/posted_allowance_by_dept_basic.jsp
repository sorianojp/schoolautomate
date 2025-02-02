<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAllowances,payroll.PReDTRME,java.util.Date" %>
<%
///added code for HR/companies.
WebInterface WI = new WebInterface(request);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
boolean bolRemoveOtherEarnings = true;

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Allowance Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerBOTTOMLEFT {
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;		
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }
	TD.BOTTOM {
		border-bottom: solid 1px #000000;		
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }		
    TD.NoBorder {
		font-family:  Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
		}
		
	.others_header{
		border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
	}	
	.others_body{		
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
	}
		
		
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
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

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

	this.processRequest(strURL);
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>

<%

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;	
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	String strHasWeekly = null;
	String strPayrollPeriod  = null;
	String[] astrSalaryBase = {"Monthly rate", "Daily Rate", "Hourly Rate"};
	boolean bolProceed = true;
	int iSearchResult = 0;
	int i = 0;

	boolean bolShowALL = false;
	if(strUserId != null && (strUserId.equals("bricks") || strUserId.equals("SA-01")) )
		bolShowALL = true;	
	boolean bolShowBorder = false;
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./posted_allowance_by_dept_basic_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Payroll Register","posted_allowance.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"posted_allowance_by_dept_basic.jsp.jsp");
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
	
	String strSchCode = dbOP.getSchoolIndex();
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	PRAllowances prAllowances = new PRAllowances();
	Vector vAllowanceList = null;	
	Vector vDepartmentList = null;	
	Vector vRetResult = null;	
	vRetResult = prAllowances.getAllAllowanceForPeriod(dbOP,request,3);
	if(vRetResult == null)
		strErrMsg = prAllowances.getErrMsg();
	else	
		iSearchResult = prAllowances.getSearchCount();
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="posted_allowance_by_dept_basic.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      EMPLOYEE ALLOWANCES::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">Salary Period</td>
      <td width="77%" colspan="3"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
		</label>
        </strong>
        <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "0.00";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
		<%if(bolIsSchool){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
	   <select name="employee_category" onChange="ReloadPage();">          
			 <option value="">ALL</option>
			 <%if (WI.fillTextValue("employee_category").equals("0")){%>
          <option value="0" selected>Non-Teaching</option>
					<option value="1">Teaching</option>
				<%} else if (WI.fillTextValue("employee_category").equals("1")){%>
					<option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
        <%}else{%>
					<option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
		<%}%>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
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
				<select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary base </td>
			<%
				strTemp = WI.fillTextValue("salary_base");
			%>
      <td colspan="3">
			<select name="salary_base" onChange="ReloadPage();">
				<option value="">ALL</option>
        <%for(i = 0; i < astrSalaryBase.length; i++){
					if(strTemp.equals(Integer.toString(i))){
				%>
				<option value="<%=i%>" selected><%=astrSalaryBase[i]%></option>
				<%}else{%>
				<option value="<%=i%>"><%=astrSalaryBase[i]%></option>
				<%}
				}%>
      </select></td>
    </tr>
 	<tr>
      <td height="25">&nbsp;</td>
      <td>Taxable/Non-Taxable</td>
      <td colspan="3">
	  	<%	strTemp = WI.fillTextValue("taxable_status"); %>
			<select name="taxable_status">
				<option value="" <%=strTemp.equals("")?"selected":"" %> > All </option>
				<option value="1" <%=strTemp.equals("1")?"selected":"" %> >Taxable</option>
				<option value="0" <%=strTemp.equals("0")?"selected":"" %> >Non - Taxable</option>
			</select>
	  </td>
    </tr>
		
		
			
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
   
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <% if (vRetResult != null && vRetResult.size() > 0 ){%>
		<tr> 
      <td height="10">&nbsp;</td>
 	  
      <td height="10" colspan="4"><div align="right">
        <div align="right"><font>         
            <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div>
      </div></td>	   
    </tr>		
		<%}%>
  </table>
  
  <% if (vRetResult != null && vRetResult.size() > 0 ){%>   
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="40" colspan="54" align="center"><strong><font color="#0000FF">EMPLOYEE ALLOWANCES RESULTS : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
  </table>
  <BR />
  <%
  		double dTotalBasic = 0d;
		double dNetPayTotal = 0d;
		double dOvertimeTtaol =0d;
		vAllowanceList = (Vector) vRetResult.elementAt(0);//allowance names	
		vDepartmentList = (Vector) vRetResult.elementAt(1);	
  %>
  <table  bgcolor="#FFFFFF" width="80%" border="0" cellspacing="0" cellpadding="0" align="center" class="TOPRIGHT">  
    <tr>      
     <td width="26%" height="33" align="center" class="headerBOTTOMLEFT"><strong>DEPARTMENT </strong></td>
	 <td width="13%" height="33" align="center" class="headerBOTTOMLEFT"><strong>BASIC PAY </strong></td>
	 <td width="11%" height="33"  align="center" class="headerBOTTOMLEFT"><strong>OVERTIME</strong></td> 
	 <% for(i = 0; i < vAllowanceList.size(); i += 3){ %>
		 <td width="11%" height="33"  align="center" class="headerBOTTOMLEFT">&nbsp;<strong><%=WI.getStrValue((String)vAllowanceList.elementAt(i+2),"")%></strong></td> 
	 <%}%>	
   </tr>
    <% 
		Vector vTemp = null;	
		int iAllowanceCount = vAllowanceList.size()/3;
		double []arrDAllownceTotal = new double [iAllowanceCount];
		double dTemp = 0d;	
      	for(i = 0; i < vDepartmentList.size(); i += 6){ 	
			if( vDepartmentList.elementAt(i) == null )	
				strTemp = "";
			else
				strTemp = (String)vDepartmentList.elementAt(i);						
			strTemp2 = (String)vDepartmentList.elementAt(i+1);
			strTemp2 = WI.getStrValue(strTemp2," ","","");		
		%>
		<tr>
		  <td  height="20" align="left" class="BOTTOMLEFT">&nbsp;<strong><%=(WI.getStrValue(strTemp,"", strTemp2, strTemp2)).toUpperCase()%></strong></td>
		  	
		 <!-- baic pay --> 
		 <% 
		 dTemp =  Double.parseDouble( WI.getStrValue((String)vDepartmentList.elementAt(i+2),"0") ); 
		 dTotalBasic +=  dTemp; %>
		
		<%		
			dTemp = Double.parseDouble( WI.getStrValue(vDepartmentList.elementAt(i+4)+"","0") ); 
			dNetPayTotal += dTemp;
		%>
		<td align="right" class="BOTTOMLEFT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</td>
		<%		
			dTemp = Double.parseDouble( WI.getStrValue(vDepartmentList.elementAt(i+5)+"","0") ); 
			dOvertimeTtaol += dTemp;
		%>
		<td  height="20" align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true) %>&nbsp; </td>
		 <% 
		 vTemp = new Vector();
		 vTemp = (Vector) vDepartmentList.elementAt(i+3);
		 for(int j = 0; j < vTemp.size(); j++){
		 	dTemp =  Double.parseDouble( WI.getStrValue((String)vTemp.elementAt(j),"0") ); 
		 	arrDAllownceTotal[j] += dTemp;
		  %>
		 	<td  height="20" align="left" class="BOTTOMLEFT">&nbsp; <%=CommonUtil.formatFloat(dTemp,true) %> </td>	
		 <%}%>	
		</tr>
	
		<%}//end of for loop %>
		<tr>
			 <td  height="30" align="left" class="BOTTOMLEFT">&nbsp;<strong> TOTAL </strong> </td>	
			  <td align="right" class="BOTTOMLEFT" height="25"><strong><%=CommonUtil.formatFloat(dNetPayTotal,true)%>&nbsp;&nbsp;</strong></td>
			  <td  height="20" align="right" class="BOTTOMLEFT"><strong> <%=CommonUtil.formatFloat(dOvertimeTtaol,true) %></strong>&nbsp; </td>	
			  <%for(i = 0; i < iAllowanceCount; i++){%>
			  	  <td  height="20" align="left" class="BOTTOMLEFT">&nbsp;<strong> <%=CommonUtil.formatFloat(arrDAllownceTotal[i],true) %></strong> </td>	
			  <%}%>
		</tr>
		
	<%}//end of if vRetResult
	%>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_pg" value="">
   <input type="hidden" name="view_all" value="1">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>