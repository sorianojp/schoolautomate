<%@ page language="java" import="utility.*,payroll.PReDTRME,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Period Setting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function viewList(table, indexname, colname, labelname, tablelist, strIndexes,  strExtraTableCond, strExtraCond, strFormField){
//	alert("table " + table);
//	alert("indexname " + indexname);
//	alert("colname " + colname);
//	alert("labelname " + labelname);
//	alert("tablelist " + tablelist);
//	alert("strIndexes " + strIndexes);
//	alert("strExtraTableCond " + strExtraTableCond);
//	alert("strExtraCond " + strExtraCond);
//	alert("strFormField " + strFormField);
	
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function DeletePeriod(){
  var vProceed = confirm('Are you sure you want to delete the unused periods for the selected year?');
  if(vProceed){	
	document.form_.delete_period.value = "1";
	this.SubmitOnce('form_');
  }
}

function CancelRecord(){
	location = "./salary_period_weekly.jsp?is_weekly=1";
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strHasWeekly = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Salary Period","salary_period_weekly.jsp");
	ReadPropertyFile readPropFile = new ReadPropertyFile();
	strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
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
														"Payroll","DTR",request.getRemoteAddr(),
														"salary_period_weekly.jsp");
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

	PReDTRME prEdtrME = new PReDTRME();
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	boolean bolReload = false;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		bolReload = true;
		if(prEdtrME.operateOnBatchWeeklyPeriod(dbOP, request) == null)
			strErrMsg = prEdtrME.getErrMsg();
		else
				strErrMsg = "Salary Period information successfully added.";
	}
 
	if(WI.fillTextValue("delete_period").length() > 0){		
		if(!prEdtrME.removeUnusedPeriod(dbOP, request))
			strErrMsg = prEdtrME.getErrMsg();
		else
			strErrMsg = "Unused salary periods removed";	
		
	}

	vRetResult  = prEdtrME.operateOnSalaryPeriodNew(dbOP, request,4, true);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prEdtrME.getErrMsg();
 %>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./salary_period_weekly.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SALARY PERIOD SETTING ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td>Salary Schedule Name </td>
		  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(8);
		else	
			strTemp = WI.fillTextValue("period_name");
		%>	  
        <td><select name="period_index">
          <%=dbOP.loadCombo("PERIOD_INDEX","PERIOD_NAME", " from pr_preload_period order by period_name",strTemp,false)%>
        </select>
          <!--table, indexname, colname, labelname, tablelist, strIndexes,  strExtraTableCond, strExtraCond, strFormField-->
          <%if(iAccessLevel > 1){%>
					<a href='javascript:viewList("pr_preload_period","period_index","period_name", "SALARY SCHEDULE NAMES", 
					"PR_EDTR_SAL_PERIOD, PR_EMP_SAL_SCHEDULE","period_index, period_index",
					" and PR_EDTR_SAL_PERIOD.IS_VALID = 1, and PR_EMP_SAL_SCHEDULE.user_index is not null",
					"","period_index");'><img src="../../../images/update.gif" border="0" ></a><font size="1">click				
      to add to the salary schedule name </font>
					<%}%>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Range</td>
      <td>
				<select name="month_fr">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_fr"))%>
        </select>
				-
				<select name="month_to">
          <option value="">&nbsp;</option>
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_to"))%>
        </select>
				<select name="year_of">
					<%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
				</select>			</td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Start of Period</td>
      <td><select name="period_start_day">
         <%
				strTemp = WI.fillTextValue("period_start_day");
				if(strTemp.compareTo("0") == 0) {%>
        <option value="0" selected>Sunday</option>
        <%}else{%>
        <option value="0">Sunday</option>
        <%}if(strTemp.compareTo("1") == 0) {%>
        <option value="1" selected>Monday</option>
        <%}else{%>
        <option value="1">Monday</option>
        <%}if(strTemp.compareTo("2") == 0) {%>
        <option value="2" selected>Tuesday</option>
        <%}else{%>
        <option value="2">Tuesday</option>
        <%}if(strTemp.compareTo("3") == 0) {%>
        <option value="3" selected>Wednesday</option>
        <%}else{%>
        <option value="3">Wednesday</option>
        <%}if(strTemp.compareTo("4") == 0) {%>
        <option value="4" selected>Thursday</option>
        <%}else{%>
        <option value="4">Thursday</option>
        <%}if(strTemp.compareTo("5") == 0) {%>
        <option value="5" selected>Friday</option>
        <%}else{%>
        <option value="5">Friday</option>
        <%}if(strTemp.compareTo("6") == 0) {%>
        <option value="6" selected>Saturday</option>
        <%}else{%>
        <option value="6">Saturday</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="20%">Cut off Day </td>
      <td width="75%"><select name="cut_off_day">
         <%
				strTemp = WI.fillTextValue("cut_off_day");
				if(strTemp.compareTo("0") == 0) {%>
        <option value="0" selected>Sunday</option>
        <%}else{%>
        <option value="0">Sunday</option>
        <%}if(strTemp.compareTo("1") == 0) {%>
        <option value="1" selected>Monday</option>
        <%}else{%>
        <option value="1">Monday</option>
        <%}if(strTemp.compareTo("2") == 0) {%>
        <option value="2" selected>Tuesday</option>
        <%}else{%>
        <option value="2">Tuesday</option>
        <%}if(strTemp.compareTo("3") == 0) {%>
        <option value="3" selected>Wednesday</option>
        <%}else{%>
        <option value="3">Wednesday</option>
        <%}if(strTemp.compareTo("4") == 0) {%>
        <option value="4" selected>Thursday</option>
        <%}else{%>
        <option value="4">Thursday</option>
        <%}if(strTemp.compareTo("5") == 0) {%>
        <option value="5" selected>Friday</option>
        <%}else{%>
        <option value="5">Friday</option>
        <%}if(strTemp.compareTo("6") == 0) {%>
        <option value="6" selected>Saturday</option>
        <%}else{%>
        <option value="6">Saturday</option>
        <%}%>
      </select></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1) {%>
    <tr> 
      <td height="35" colspan="3" align="center" valign="bottom"><font size="1"> 
 				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries          
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
      Click to clear</font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="10" colspan="3" align="center">
			<%if(iAccessLevel == 2){%>
			<!--
			<a href="javascript:DeletePeriod()"><img src="../../../images/delete.gif" border="0"></a>
			-->
			<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeletePeriod();">
			<font size="1">Delete unused salary Periods</font>
			<%}%>			</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#D8D569"> 
      <td height="25" colspan="6" align="center" bgcolor="#FFFF99" class="thinborder"><strong>SALARY 
      PERIOD INFORMATION </strong></td>
    </tr>
    <tr>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>PERIOD NAME </strong></font></td>
      <td width="14%" height="25" align="center" class="thinborder"><font size="1"><strong>MONTH-YEAR</strong></font></td>
      <td width="23%" align="center" class="thinborder"><font size="1"><strong>SALARY 
        PERIOD RANGE</strong></font></td>
      <td width="23%" align="center" class="thinborder"><font size="1"><strong> 
        SALARY PERIOD CUT-OFF RANGE</strong></font></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>SALARY 
        PERIOD</strong></font></td>
      <%if(WI.fillTextValue("view_expired").compareTo("1") != 0){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
      <%}%>
    </tr>
    <%String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
	  String[] astrPeriod  = {"","1","2","3","4","Whole Month", "5", "6"};
 	 for(int i =0; i < vRetResult.size(); i += 10){
 	 %>
    <tr>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 9))%></td> 
      <td height="25" class="thinborder"> &nbsp;<%=astrConvertMonth[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%> <%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),""," to ","&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%></td>
      <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i + 1)%> to <%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" align="center"><%=astrPeriod[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <%if(WI.fillTextValue("view_expired").compareTo("1") != 0){%>
      <td class="thinborder" align="center"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"> </a> <%}else{%>
        N/A 
        <%}%> </td>
      <%}%>
    </tr>
    <%}//end of for loop%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="delete_period">
<input type="hidden" name="is_weekly" value="1">
<!--
<input type="hidden" name="is_for_period" value="1">
-->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
