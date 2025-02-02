<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn" %>
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
<title>Employees with Official Business</title>
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
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.dtr_op.print_page.value = 1;
	document.dtr_op.submit();
}
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	document.dtr_op.print_page.value = "";
	document.dtr_op.submit();
}

function ViewRecordDetail(index){
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.SummaryDetail.value="1";
	document.dtr_op.emp_id.value=index;
	document.dtr_op.emp_type.value ="";
	document.dtr_op.c_index.value ="";
	document.dtr_op.d_index.value ="";
	document.dtr_op.submit();
}
function ViewRecords()
{
	document.dtr_op.print_page.value = "";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
function ViewDetails(strUserIndex,strDateFrom, strDateTo,strEmpID){
	var pageLoc = "./summary_emp_undertime_detail.jsp?strUserIndex=" + strUserIndex+"&strDateFrom="+strDateFrom+"&strDateTo="+strDateTo+
	"&emp_id=" + strEmpID;
		var win=window.open(pageLoc,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./summary_emp_with_ob_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	boolean bolHasTeam = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Employees with OB",
								"summary_emp_with_ob.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");								
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
														"summary_emp_with_ob.jsp");	
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

ReportEDTRExtn RE = new ReportEDTRExtn(request);


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
if(bolIsSchool)
   strTemp = "College";
else
   strTemp = "Division";
	String[] astrSortByName    = {strTemp, "Department","Firstname","Lastname"};
	String[] astrSortByVal     = {"c_code","d_code","fname","lname"};


String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};

if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = RE.searchWithOBForPeriod(dbOP);
	if (vRetResult == null) 
		strErrMsg = RE.getErrMsg();
	else iSearchResult = RE.getSearchCount();
	
	if (RE.defSearchSize  != 0){
		iPageCount = iSearchResult/RE.defSearchSize;
		if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;		
	}
}

String strSchCode = dbOP.getSchoolIndex();
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

%>
<form action="./summary_emp_with_ob.jsp" name="dtr_op" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        SUMMARY OF EMPLOYEES WITH OFFICIAL BUSINESS/TIME PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font color=\"#FF0000\" size=\"3\"><strong>","</strong></font>","")%></strong></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date &nbsp;&nbsp;&nbsp;&nbsp;:: 
        &nbsp;From: 
        <input name="from_date" type="text" size="12" class="textbox"
		 		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
				 value="<%=WI.fillTextValue("from_date")%>" style="text-align:right">
          <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" 
		  onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		  <img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To : 
          <input name="to_date" type="text"  size="12" class="textbox" 
				  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.fillTextValue("to_date")%>" style="text-align:right">
          <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" 
		  onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		  <img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
  </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="26">&nbsp; </td>
      <td height="25"> Month and Year</td>
      <td width="590" height="25"><select name="month_of">
			<option value="" selected>&nbsp;</option>
	  <% 
	  	for (int i = 1; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("month_of"),"0")) == i) {
	  %>
	  	<option value="<%=i%>" selected><%=astrMonth[i]%></option>	  
	  <%}else{%>
	  	<option value="<%=i%>"><%=astrMonth[i]%></option>
	  <%} 
	  } // end for lop%>
	  </select>
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">Employee ID</td>
      <td height="25"><select name="id_number_con">
          <%=RE.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select><input name="emp_id" type="text" size="12" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>">      </td>
    </tr>
		 <%if(strSchCode.startsWith("AUF")){%>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25">Employment Category </td>
      <td height="25"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				strTemp = WI.fillTextValue("emp_type_catg");
				for(int i = 0;i < astrCategory.length;i++){
					if(strTemp.equals(Integer.toString(i))) {%>
        <option value="<%=i%>" selected><%=astrCategory[i]%></option>
        <%}else{%>
        <option value="<%=i%>"> <%=astrCategory[i]%></option>
        <%}
							}%>
      </select></td>
    </tr>
		<%}%>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp; </td>
      <td height="25">Position</td>
      <td height="25"><strong> 
        <%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
					WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
					" order by EMP_TYPE_NAME asc", strTemp2, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="24"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="24"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
		strTemp = WI.fillTextValue("c_index");
		if (strTemp.length()<1) strTemp="0";
	   if(strTemp.compareTo("0") ==0)
		   strTemp2 = "Offices";
	   else
		   strTemp2 = "Department";
	%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25"> <select name="d_index">
          <% if(strTemp.compareTo("") ==0){//only if from non college.%>
          <option value="">All</option>
          <%}else{%>
          <option value="">All</option>
          <%} strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25">Office/Dept filter</td>
      <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else	
					strTemp = "";
			%>
		  <td><input type="checkbox" name="show_all" value="1" <%=strTemp%>> check to show all&nbsp;</td>
	  </tr>		
    <tr bgcolor="#FFFFFF"> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <% if (strSchCode.startsWith("AUF")) {%>
    <%}%>
    <tr bgcolor="#FFFFFF"> 
      <td width="4%">&nbsp;</td>
      <td height="18" colspan="4"><strong>SORT BY</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td><font color="#FFFFFF">vc</font></td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="31%" height="25"><select name="sort_by1">
        <option value="">N/A</option>
        <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td width="32%"><select name="sort_by2">
        <option value="">N/A</option>
        <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td width="30%"><select name="sort_by3">
        <option value="">N/A</option>
        <%=RE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="sort_by1_con">
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
      <td height="25"><select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><a href="javascript:ViewRecords()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<% 
	if (vRetResult !=null && vRetResult.size()> 0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2" align="right"><font size="2">Number of Employees / rows Per 
        Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 15; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
        <a href="javascript:PrintPg();"> <img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print result</font> </td>
    </tr>
		<% if (WI.fillTextValue("show_all").length() == 0){ %>
    <tr>
      <td width="77%" height="25">&nbsp;&nbsp;<strong>Total : <%=iSearchResult%>         
        - Showing(<%=RE.getDisplayRange()%>) </strong>&nbsp;&nbsp;
      </td>
      <td width="23%" nowrap>&nbsp;
			<%
			if(iPageCount > 1) {%>
        Jump To page: 
        <select name="jumpto" onChange="ViewRecords();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EBF2FA"> 
      <%  if (vRetResult != null) 
	  		strTemp = (String)vRetResult.elementAt(0) + WI.getStrValue((String)vRetResult.elementAt(1)," - " , "", ""); 
		  else
		  	strTemp = "";	
  	%>
      <td height="25"  colspan="5" align="center" class="thinborder"><strong>SEARCH RESULT </strong></td>
    </tr>
    <tr> 
      <td width="8%" height="25" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="25%" height="25" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="12%" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="20%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">DATE</font></strong> </td>
      <td width="35%" height="25" align="center" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>DETAILS </strong></font></td>
    </tr>
    <%
	//System.out.println(vRetResult);
	for ( int i = 0 ; i< vRetResult.size(); i+=30){ 
%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3),
	  											(String)vRetResult.elementAt(i+4),
												(String)vRetResult.elementAt(i+5),4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+21)%></td>
			<% 
				strTemp = (String)vRetResult.elementAt(i+19);
				if(strTemp == null){
					strTemp2 = (String)vRetResult.elementAt(i+14); 
 					strTemp2 = strTemp2 + "<br>"+CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 15))) + " to " +
									CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 16)));

 				} else {
					strTemp2 = (String)vRetResult.elementAt(i+14) + " - " + (String)vRetResult.elementAt(i+19); 
				}
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12))%><br>
			<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
    </tr>
    <%} // end for loop%>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
   <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type=hidden name="viewRecords" value="0">
  <input type="hidden" name="show_only_total" value="1">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>