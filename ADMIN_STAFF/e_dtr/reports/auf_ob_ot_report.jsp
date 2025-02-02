<%@ page language="java" import="utility.*,java.util.Vector,hr.HRStatsReports" %>
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
<title>Official Business</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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
	
    TD.thinborderBottom {
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
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.print_page.value = "";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	this.SubmitOnce("dtr_op");
}

function ViewRecordDetail(index){
	document.dtr_op.print_page.value = "";

	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.SummaryDetail.value="1";
	document.dtr_op.emp_id.value=index;
	document.dtr_op.emp_type.value ="";
	document.dtr_op.c_index.value ="";
	document.dtr_op.d_index.value ="";
	this.SubmitOnce("dtr_op");
}
function ViewRecords()
{
	document.dtr_op.print_page.value = "";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	this.SubmitOnce("dtr_op");
}
function PrintPage()
{
	document.dtr_op.print_page.value = "1";
	document.dtr_op.submit();
}

function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
		var win=window.open(pgLoc,"SearchID",		'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
}

function ChangeLabel(){
	if (document.dtr_op.seminar_type){
		if (document.dtr_op.seminar_type.selectedIndex != 0){
		  if (document.getElementById("label_")) 
			document.getElementById("label_").innerHTML = 
				document.dtr_op.seminar_type[document.dtr_op.seminar_type.selectedIndex].text;
			document.dtr_op.obot_label.value = 
				document.dtr_op.seminar_type[document.dtr_op.seminar_type.selectedIndex].text;
		}else{
		  if (document.getElementById("label_")) 
			document.getElementById("label_").innerHTML = "Official Business / Official Time";
			document.dtr_op.obot_label.value = "Official Business / Official Time";
		}
	
	}


	
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./auf_ob_ot_report_print.jsp" />
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
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-OB / OT Reports",
								"auf_ob_ot_report.jsp");
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
														"auf_ob_ot_report.jsp");
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
String[] astrSortByName    = {"College","Department","Date","Scope", "Seminar Type"};
String[] astrSortByVal     = {"c_code","d_code","DATE_RANGE_FR","train_scope","seminar_type"};


HRStatsReports RE = new HRStatsReports(request);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = RE.hrDemoTrainings(dbOP);
	if (vRetResult == null) 
		strErrMsg = RE.getErrMsg();
}
%>
<form action="./auf_ob_ot_report.jsp" name="dtr_op" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        EMPLOYEE WITH OFFICIAL BUSINESS / OFFICIAL TIME RECORD ::::</strong></font></td>
    </tr>
  <tr> 
      <td height="25">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="5%"><p>&nbsp;</p>      </td>
    <td width="95%">Date &nbsp;&nbsp;&nbsp;&nbsp;:: &nbsp;From:
      <input name="date_from" type="text" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_from','/')" onKeyUp="AllowOnlyIntegerExtn('dtr_op','date_from','/')" 
		value="<%=WI.fillTextValue("date_from")%>" size="12">
      <a href="javascript:show_calendar('dtr_op.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
          :
      <input name="date_to" type="text" 
	  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_to','/')" 
	  onKeyUp="AllowOnlyIntegerExtn('dtr_op','date_to','/')"
	  value="<%=WI.fillTextValue("date_to")%>"  size="12" >
      <a href="javascript:show_calendar('dtr_op.date_to');" title="Click to select date" 
	  	onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  </td>
  </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">Employee ID</td>
      <td width="12%" height="25"><input name="emp_id" type="text" size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>"></td>
      <td width="72%">
	  <a href="javascript:OpenSearch()"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
<%if (strSchCode.startsWith("AUF")) { %>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="24">Report Type </td>
      <td height="24" colspan="2"><strong>
        <select name="seminar_type" onChange="ChangeLabel()">
		  <option value="">ALL </option>
		<% if (WI.fillTextValue("seminar_type").equals("2")) {%> 
          <option value="2" selected >Official Business</option>
		<%}else{%> 
          <option value="2"> Official Business</option>		
		<%} if (WI.fillTextValue("seminar_type").equals("1")) {%> 
          <option value="1" selected>Official Time</option>
		<%}else{%> 
          <option value="1"> Official Time</option>
		 <%}%> 
        </select><input type="hidden" name="obot_label" 
					value="<%=WI.fillTextValue("obot_label")%>">
      </strong></td>
    </tr>
<%}%>	
		<%//if(strSchCode.startsWith("AUF")){%>
		<!--
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="24">Employment Category </td>
      <td height="24" colspan="2"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				//			strTemp = WI.fillTextValue("emp_type_catg");
				//			for(int i = 0;i < astrCategory.length;i++){
				//				if(strTemp.equals(Integer.toString(i))) {%>
        		
        <option value="<%//=i%>" selected><%//=astrCategory[i]%></option>
        <%//}else{%>
        <option value="<%//=i%>"> <%//=astrCategory[i]%></option>
        <%//}
					//		}%>
      </select></td>
    </tr>
		-->
		<%//}%>
    <tr bgcolor="#FFFFFF"> 
      <td width="4%">&nbsp;</td>
      <td width="12%" height="24">Position</td>
      <td height="24" colspan="2"><strong> 
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
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25" colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
		strTemp = WI.fillTextValue("c_index");
		if (strTemp.length()<1) strTemp="0";
	   if(strTemp.compareTo("0") ==0)
		   strTemp2 = "Offices";
	   else
		   strTemp2 = "Department";
	%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25" colspan="2"> <select name="d_index">
          <% if(strTemp.compareTo("") ==0){//only if from non college.%>
          <option value="">All</option>
          <%}else{%>
          <option value="">All</option>
          <%} strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> 
        </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="2%">&nbsp;</td>
      <td width="10%" height="25">Sort By : </td>
      <td width="20%" height="25"><select name="sort_by1">
          <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="19%"><select name="sort_by2">
        <option value="">N/A</option>
        <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td width="20%"><select name="sort_by3">
        <option value="">N/A</option>
        <%=RE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td width="29%" height="25"><select name="sort_by4">
        <option value="">N/A</option>
        <%=RE.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%>
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
      <td height="25"><select name="sort_by4_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25" colspan="5"><a href="javascript:ViewRecords()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <% 
  	if (vRetResult !=null && vRetResult.size() > 0){
  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="46%" align="right">
	  	<a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a> 
        print report &nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFE6E6"> 
      <% strTemp = WI.fillTextValue("date_from") + 
					WI.getStrValue(WI.fillTextValue("date_to")," -  ","",""); %>
      <td height="25"  colspan="6" align="center" bgcolor="#E8EBFD" class="thinborder"><strong>Reports  on <label id="label_"> Official Business / Official Time </label> 
	  <% if (strTemp.length() != 0)  {%>&nbsp;&nbsp; <%=strTemp%> <%}%>
</strong></td>
    </tr>
    <tr align="center"> 
      <td height="20" colspan="2" bgcolor="#EBEBEB" class="thinborder"><strong>NAME</strong></td>
      <td width="17%" bgcolor="#EBEBEB" class="thinborder"><strong>DATE</strong></td>
      <td width="37%" height="20" bgcolor="#EBEBEB" class="thinborder"><strong>BUSINESS &amp; DESTINATION </strong></td>
      <td width="12%" height="20" bgcolor="#EBEBEB" class="thinborder"><strong>CATEGORY</strong></td>
      <td width="12%" height="20" bgcolor="#EBEBEB" class="thinborder"><strong>BUDGET</strong></td>
    </tr>
<%  strTemp2 = "";strTemp3 = "";
	String strUserID = "";
	String[] astrConvertDurationUnit={" hour(s)", " day(s)", " week(s)", " month(s)", " year(s)"};
	
	for ( int i = 2 ; i< vRetResult.size(); i+=17){ 
%>
    <tr> 
      <td width="16%" height="21" class="thinborder">
	  <% if (!strUserID.equals((String)vRetResult.elementAt(i))) { %> 
	  <%=WI.formatName((String)vRetResult.elementAt(i+12),
	  													(String)vRetResult.elementAt(i+13),
														(String)vRetResult.elementAt(i+14),4)%>
	  <%}else{%>&nbsp;<%}%> 
														<br>
	  <% if (!strUserID.equals((String)vRetResult.elementAt(i))) {
	  	strUserID = (String)vRetResult.elementAt(i);
	  %> 
	  <%=strUserID%>
	  <%}else{%>&nbsp;<%}%>
	  </td>
      <td width="6%" class="thinborderBottom">&nbsp;<br>
	  	<% if ((String)vRetResult.elementAt(i+1) != null){%> 
			<%=(String)vRetResult.elementAt(i+1)%> 
		<%}else{%> 
			<%=(String)vRetResult.elementAt(i+2)%> 
		<%}%> 
	  
	  </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+9) + WI.getStrValue((String)vRetResult.elementAt(i+10)," - " ,"","")%> <br>
	 <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6)," ::: ","","");
	    if (strTemp.length() > 0) {
			if ((String)vRetResult.elementAt(i+7) != null) 
				strTemp +=  astrConvertDurationUnit[Integer.parseInt((String)vRetResult.elementAt(i+7))];
		}else strTemp = "&nbsp;";%> <%=strTemp%>	  
	  </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%><br>
	  
	 <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	 	if (strTemp.length() > 0)
			strTemp +=WI.getStrValue((String)vRetResult.elementAt(i+15),", ","","") ;
		else
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15)) ;
	 %>	&nbsp;<%=strTemp%>
	  </td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type=hidden name="viewRecords" value="0">
  <input type=hidden name="show_all" value="1">
  <input type="hidden" name="edtr_search" value="1">
  <input type="hidden" name="print_page">
<script language="javascript">
	ChangeLabel();
</script>
</form>
</body>
</html>
<% dbOP.cleanUP(); %>