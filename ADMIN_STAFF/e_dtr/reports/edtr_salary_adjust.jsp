<%@ page language="java" import="utility.*, java.util.Vector, eDTR.ReportEDTRExtn, eDTR.TimeInTimeOut, 
																					java.util.Calendar, payroll.PReDTRME"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of Adjustments for payroll</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="Javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.reloadpage.value="1";
	document.form_.viewRecords.value ="0";
	document.form_.recompute.value="";
	document.form_.submit();
}

function ViewRecords()
{
	document.form_.print_page.value="";
	document.form_.reloadpage.value="1";
	document.form_.viewRecords.value="1";
	document.form_.recompute.value="";
	document.form_.submit();
}

function Recompute()
{
	document.form_.print_page.value="";
	document.form_.reloadpage.value="1";
	document.form_.recompute.value="1";
	document.form_.viewRecords.value="1";
	document.form_.submit();
}

function CallPrint()
{
	document.form_.print_page.value="1";
	document.form_.submit();
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
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
	document.form_.print_page.value="";
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
function loadSalPeriods() {
	var strMonth = document.form_.strMonth.value;
	var strYear = document.form_.sy_.value;
	var strWeekly = null;
	strMonth = eval(strMonth) - 1;
	if(document.form_.is_weekly)
		strWeekly = document.form_.is_weekly.value;
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&has_all=1&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./edtr_salary_adjust_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Report - Employees with Adjustments",
								"emp_dtr_adjustments.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"dtr_view.jsp");	
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

ReportEDTRExtn RptExtn = new ReportEDTRExtn(request);
TimeInTimeOut tRec = new TimeInTimeOut();
PReDTRME prEdtrME = new PReDTRME();
Vector vSalaryPeriod = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
strTemp = WI.fillTextValue("info_index");

String strDateFr = null;
String strDateTo = null;
Calendar calendar = Calendar.getInstance();
String strMonths = WI.fillTextValue("strMonth");
String strYear = WI.fillTextValue("sy_");
int iMonth = 0;
int i = 0;
int iJumpTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("jumpto"),"1"));
double dAmountDiff = 0d;
double dDeducted = 0d;

if(strMonths.length() == 0)
	strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
if(strYear.length() == 0)
	strYear = Integer.toString(calendar.get(Calendar.YEAR));

iMonth = Integer.parseInt(strMonths);

int iAction = Integer.parseInt(WI.getStrValue(strTemp,"0"));

if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = RptExtn.operateOnSalAdjustments(dbOP);
	if (vRetResult == null || vRetResult.size() == 0) {	
		strErrMsg = RptExtn.getErrMsg();
	}else{
		iSearchResult = RptExtn.getSearchCount();	
	}
	
}
vSalaryPeriod = prEdtrME.getSalaryPeriods(dbOP, request, Integer.toString(iMonth-1), strYear);
%>
<form action="./edtr_salary_adjust.jsp" name="form_" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="3">
  <tr bgcolor="#FFFFFF">
    <td height="25" colspan="3" align="center" bgcolor="#A49A6A" class="footerDynamic"><strong><font color="#FFFFFF">SUMMARY OF SALARY ADJUSTMENTS</font></strong> </td>
    </tr>
  <tr bgcolor="#FFFFFF">
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><font color="#FF0000" size="3"><strong>&nbsp;
        <%=WI.getStrValue(strErrMsg)%></strong></font></td>
  </tr>
  
  <tr bgcolor="#FFFFFF">
    <td height="25">&nbsp;</td>
    <td height="25">Month / Year</td>
    <td height="25"><select name="strMonth" onChange="loadSalPeriods();">
      <%
	  int iDefMonth = Integer.parseInt(strMonths);
	  	for (i= 1; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
      <option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
      <%} // end for lop%>
    </select>
      <input type="hidden" name="month_label">
      <%
			strTemp = WI.fillTextValue("sy_");
			if (strTemp.length() == 0)
				strTemp = strYear;
		%>
      <select name="sy_" onChange="loadSalPeriods();">
        <%=dbOP.loadComboYear(WI.fillTextValue("sy_"),2,1)%>
      </select></td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td height="25">&nbsp;</td>
    <td height="25">Salary Cut-Off</td>
    <td height="25">
		<label id="sal_periods">
		<select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage()">
      <option value="">&nbsp;</option>
      <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");

		for(i= 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10){
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
				strDateFr = (String)vSalaryPeriod.elementAt(i+1);
				strDateTo = (String)vSalaryPeriod.elementAt(i+2);			
				%>
      <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
      <%}else{%>
      <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
      <%}//end of if condition.
				 }//end of for loop.%>
    </select>
		</label>		</td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td width="2%" height="25">&nbsp;</td>
    <td width="21%" height="25">Enter Employee ID </td>
    <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%if(strSchCode.startsWith("AUF")){%>
				<tr bgcolor="#FFFFFF">
          <td height="25">Employment Category </td>
					<%
						strTemp = WI.fillTextValue("emp_type_catg");
					%>
          <td height="25"><select name="emp_type_catg" onChange="ReloadPage();">
            <option value="">ALL</option>
            <%
							for(i= 0;i < astrCategory.length;i++){
								if(strTemp.equals(Integer.toString(i))) {%>            		
							%>
            <option value="<%=i%>" selected><%=astrCategory[i]%></option>
            <%}else{%>
            <option value="<%=i%>"> <%=astrCategory[i]%></option>
            <%}
							}%>
          </select></td>
        </tr>
				<%}%>
        <tr bgcolor="#FFFFFF"> 
          <td width="20%" height="25">Position</td>
          <td width="80%" height="25"><strong> 
            <select name="emp_type_index">
              <option value="">ALL</option>
              <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
							WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
							" order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> 
            </select>
            </strong></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
          <td height="25"><select name="c_index" onChange="ReloadPage();">
              <option value="">N/A</option>
              <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length() == 0) 
			strTemp="0";
   if(strTemp.equals("0"))
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";
%>
              <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td height="25"><%=strTemp2%></td>
          <td height="25"> <select name="d_index">
              <option value="">All</option>
              <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+			
			  			strTemp+" order by d_name asc",WI.fillTextValue("d_index"), false)%> 
			  </select>		  </td>
        </tr>
      </table></td>
  </tr>
  
  <tr bgcolor="#FFFFFF">
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2">
		<%if (WI.fillTextValue("show_all").equals("1")) 
			strTemp = "checked";
			else
				strTemp = "";
		%>
      <input type="checkbox" name="show_all" value="1" <%=strTemp%>>
      <font size="1">check to show all</font> </td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2">&nbsp;</td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecords();"> 
    <font size="1">click to proceed</font>
		</td>
  </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td width="56%"><b>Total Records: <%=iSearchResult%>
					<% if (!WI.fillTextValue("show_all").equals("1")) {%>
			- Showing(<%=RptExtn.getDisplayRange()%>)
			<%}%>
		</b></td>
		<td width="27%">&nbsp;
      <% 
			if (!WI.fillTextValue("show_all").equals("1")) {
			iPageCount = iSearchResult/RptExtn.defSearchSize;
			if(iSearchResult % RptExtn.defSearchSize > 0) ++iPageCount;		
			if(iJumpTo > iPageCount)
				iJumpTo = iPageCount;

			if (iPageCount > 1){%> Jump To page:
			<select name="jumpto" onChange="ViewRecords();">
				<%
							strTemp = request.getParameter("jumpto");
							if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
							for(i =1; i<= iPageCount; ++i){
							if(i == Integer.parseInt(strTemp)){%>
				<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}
							} // end for loop%>
			</select>
			<%}// pagecount
			}%> 
		</td>
		<td width="17%"><a href="javascript:CallPrint()"> <img src="../../../images/print.gif" border="0"></a> <font size="1"> print list</font></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="1" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
			<tr bgcolor="#006A6A"> 
		<% strTemp =strDateFr + " - " + strDateTo; %>
				<td height="25"  colspan="10" align="center" bgcolor="#F8EFF7" class="thinborder"><strong>LIST 
				OF EMPLOYEE SALARY ADJUSTMENTS (<%=strTemp%>)</strong></td>
			</tr>
			<tr>
			  <td width="11%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMP ID</font></strong></td> 
				<td width="28%" height="25" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
				<td width="9%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>DEDUCTED<br>
			  AWOL</strong></font></td>
				<td width="9%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>AWOL<br>
TO DEDUCT </strong></font></td>
				<td width="9%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong> DIFFERENCE</strong></font></td>
				<td width="9%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong><font size="1"><strong><font size="1"><strong>DEDUCTED<br>
LATE/UT</strong></font></strong></font></strong></font></td>
				<td width="9%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>LATE/UT<br>
TO DEDUCT</strong></font></td>
				<td width="9%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong> DIFFERENCE </strong></font></td>
        <td width="7%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>SELECT<br>
        </strong>
            <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
</font></td>
		 </tr>
		 <%
		 	int iCount = 1;
		 for(i = 0; i < vRetResult.size(); i+=14, iCount++){%>
		 <tr>
		 	 <input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
		   <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
			<td height="20" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4)%></td> 
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dDeducted = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>            
			<%
				strTemp = (String)vRetResult.elementAt(i+12);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dAmountDiff = dDeducted - Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat(dAmountDiff, true);
				if(dAmountDiff == 0d)
					strTemp = "";
			%>
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+9);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dDeducted = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+10);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dAmountDiff = dDeducted - Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat(dAmountDiff, true);
				if(dAmountDiff == 0d)
					strTemp = "";
			%>			
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		  <td align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1"></td>
	  </tr>	
		<%}%>
		 <tr> 
			<td height="20" colspan="9" class="thinborder"><input type="hidden" name="emp_count" value="<%=iCount%>"></td> 
		</tr>			
	</table>
	<!--
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF"><input type="button" name="122" value=" Recompute " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:Recompute();"></td>
    </tr>
  </table>
	-->
	<%}%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>     
<input type="hidden" name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>"> 
<input type="hidden" name="page_action">
<input type="hidden" name="viewRecords" value="0"> 
<input type="hidden" name="info_index">
<input type="hidden" name="recompute">
<input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>