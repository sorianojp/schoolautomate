<%@ page language="java" import="utility.*,eDTR.ReportEDTRExtn,java.util.Vector" %>
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
<title>Summary of Employee Breaks</title>
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
<style>
	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPg() {
	document.form_.print_page.value = 1;
	document.form_.submit();
}
function ViewRD(strEmpID)
{
//popup window here. 
	var checkvalue;
	if (document.form_.show_awol.checked) checkvalue =1;
	else checkvalue = 0;
	
	var pgLoc = "./summary_emp_with_awol_detail.jsp?emp_id="+escape(strEmpID)+
	"&date_fr="+escape(document.form_.date_fr.value)+
	"&date_to="+escape(document.form_.date_to.value)+"&show_awol="+checkvalue+
	"&strMonth="+document.form_.strMonth[document.form_.strMonth.selectedIndex].value+
	"&year="+document.form_.year_of.value;
	var win=window.open(pgLoc,"ShowAwolDetails",'width=550,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function finalize(){
//	document.all.processing.style.visibility = "visible";
	var objCOAInput = document.getElementById("finalize_dtr");

	this.InitXmlHttpObject2(objCOAInput, 2, 'processing...<br><img src="../../../Ajax/ajax-loader_small_black.gif">');//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=600&date_fr="+document.form_.date_fr.value+
	"&date_to="+document.form_.date_fr.value+"&strMonth="+document.form_.strMonth.value+
	"&emp_id="+document.form_.id_number.value;
	this.processRequest(strURL);
 //	document.all.processing.style.visibility = "hidden";
}

</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_page").equals("1")) {%>
		<jsp:forward page="./emp_breaks_print.jsp" />		
	<%return;}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics-Employee Breaks","emp_breaks.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_breaks.jsp");	
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
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

String[] astrSortByName    = {"ID #", "Lastname", "Emp. Type", "Break Duration"};
String[] astrSortByVal     = {"id_number", "lname", "EMP_TYPE_NAME", "break_duration"};

int iSearchResult = 0;
int i = 0;

ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
String strCurDate = null;
if(WI.fillTextValue("searchEmployee").equals("1")){
	vRetResult = rptExtn.generateEmployeeBreaks(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rptExtn.getErrMsg();
	else
		iSearchResult = rptExtn.getSearchCount();
}

String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
%>
<form action="./emp_breaks.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
      SUMMARY OF EMPLOYEE BREAK PAGE ::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date</td>
      <td><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <font size="1">(leave 'date to' field empty for a specific date)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Month / Year </td>
      <td><select name="month_of">
	  <% 
	  	for (i = 0; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("month_of"),"0")) == i) {
	  %>
	  	<option value="<%=i%>" selected><%=astrMonth[i]%></option>	  
	  <%}else{%>
	  	<option value="<%=i%>"><%=astrMonth[i]%></option>
	  <%} 
	  } // end for lop%>
	  </select> <select name="year_of">
      <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
    </select>
		<font size="1">(selecting a month will overwrite date(s) entry)</font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%" class="fontsize11">Employee ID </td>
      <td width="75%">
				<select name="id_number_con">
				<%=rptExtn.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
				</select>
				<input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td><select name="lname_con">
          <%=rptExtn.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td><select name="fname_con">
          <%=rptExtn.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Emp. Tenure </td>
      <td> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Position&nbsp;</td>
      <td><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
	strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");

if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Office/Dept</td>
      <td><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Break Duration(in min)</td>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("break_duration"),"30");
			%>
      <td class="fontsize11"><input type="text" name="break_duration" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="3"></td>
    </tr>
    
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3" class="fontsize11"><strong>SORT BY</strong></td>
    </tr>
    
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="30%"><select name="sort_by1">
        <option value="">N/A</option>
        <%=rptExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td width="64%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=rptExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td height="25"><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
	if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="button" value=" Proceed " name="proceed" onClick="javascript:SearchEmployee();" style="font-size:11px; height:28px;border: 1px solid #FF0000;"> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" align="right">
	    <font size="2">Number of Employees / rows Per Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
				<a href="javascript:PrintPg();">
        <img src="../../../images/print.gif" width="58" height="26" border="0">
				</a> 
        <font size="1">click to print result</font>	  </td>
    </tr>
    <tr>
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">SEARCH
        RESULT</font></strong></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> - Showing(<%=rptExtn.getDisplayRange()%>)</b></td>
      <td width="34%" align="right">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/rptExtn.defSearchSize;
		if(iSearchResult % rptExtn.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
Jump To page:
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
        <%}%>      </td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="12%" height="25" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
          ID</font></strong></td>
      <td width="32%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
          NAME </font></strong></td>
      <td width="31%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
          OFFICE</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">BREAK <br>
      (in min)</font></strong></td>
    </tr>
    <%
		for(i = 0 ; i < vRetResult.size(); i +=20){
				if(strCurDate == null || !((String)vRetResult.elementAt(i + 11)).equals(strCurDate)){
					strCurDate = (String)vRetResult.elementAt(i + 11);
		%>
    <tr>
      <td height="25" colspan="5" class="thinborder"><strong>DATE : <%=strCurDate%></strong></td>
    </tr>
		<%}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder">&nbsp;
        <% 
	  	strTemp = "";
	  	if(vRetResult.elementAt(i + 7) != null) {
	  		if(vRetResult.elementAt(i + 8) != null) {
				strTemp = (String)vRetResult.elementAt(i + 7) + " / "  + (String)vRetResult.elementAt(i + 8);
			}else{
				strTemp = (String)vRetResult.elementAt(i + 7);
			}//end of inner loop/
	     }else 
	 		if(vRetResult.elementAt(i + 8) != null){ 
				strTemp = (String)vRetResult.elementAt(i + 8);
			}
	  %>
        <%=strTemp%> </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td align="center" class="thinborder"> <%=(String)vRetResult.elementAt(i + 12)%></td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%">&nbsp;</td>
    </tr>
  </table>
<%}//only if vRetResult not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="print_page" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>