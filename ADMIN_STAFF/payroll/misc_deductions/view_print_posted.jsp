<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.	

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="print_posted_deductions.jsp"/>
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-View/Print Posted","view_print_posted.jsp");

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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"view_print_posted.jsp");
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
Vector vRetResult = null;
PRMiscDeduction prMiscDed = new PRMiscDeduction(request);
boolean bolShowDeducted = false;
double dTemp = 0d;
int iSearchResult = 0;

	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName = {"Employee ID","Lastname",strTemp,"Department", "Deduction Name"};
	String[] astrSortByVal  = {"emp.id_number","emp.lname","c_name","d_name", "pre_deduct_name"};
	String[] astrUserStat  = {"Show only for resigned employees", "Show only valid employees"};

if(WI.fillTextValue("proceedclicked").length() > 0){
	vRetResult = prMiscDed.searchMiscDeductions(dbOP);
	if (vRetResult == null)
		strErrMsg = prMiscDed.getErrMsg();
	else
		iSearchResult = prMiscDed.getSearchCount();
}

if (WI.fillTextValue("staff_type").compareTo("0") == 0) 
	strTemp = "8";
else strTemp = "7";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View/print posted deductions</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function ProceedClicked(){
	document.form_.proceedclicked.value= "1";
	ReloadPage();
}


//function PrintPg(){
//	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
//	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
//	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";
//	document.bgColor = "#FFFFFF";
//	
//	document.getElementById('header').deleteRow(0);
//	document.getElementById('header').deleteRow(0);
//	//strTemp is set in Java code above
//	for (i=0; i<<%=strTemp%>; ++i)
//		document.getElementById('searchTable').deleteRow(0);
//	if (document.getElementById('search1'))
//		document.getElementById('search1').getElementsByTagName("tr")[0].style.backgroundColor = "#FFFFFF";
//	if (document.getElementById('search2'))
//		document.getElementById('search2').getElementsByTagName("tr")[0].style.backgroundColor = "#FFFFFF";		
//	document.getElementById('myADTable').deleteRow(1);
//	this.insRow(0, 1, strInfo);
//	this.insRow(1, 1, "&nbsp");
//	
//	document.getElementById('footer').deleteRow(0);	
//	document.getElementById('footer').deleteRow(0);
//	window.print();
//}

function PrintPg() {
	document.form_.print_page.value = "1";
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
-->
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<body  bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./view_print_posted.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL : MISC. DEDUCTIONS : VIEW/PRINT POSTED DEDUCTIONS PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="23" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg,"&nbsp")%></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="searchTable">

    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%">DATE</td>
      <td colspan="2"><strong> 
        <% strTemp= WI.fillTextValue("date_from");%>
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </strong> to&nbsp; <strong> 
        <%strTemp= WI.fillTextValue("date_to");%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		</strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee Type</td>
      <td height="29"  colspan="2">
	  	<%
			strTemp = WI.fillTextValue("staff_type");
		%>
	  	<select name="staff_type" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%if (strTemp.equals("1")){%>
          <option value="1" selected>Non-teaching</option>
          <%}else{%>
          <option value="1" >Non-teaching</option>
          <%}%>
          <%if (strTemp.equals("0")){%>
          <option value="0" selected>Teaching</option>
          <%}else{%>
          <option value="0" >Teaching</option>
          <%}%>
        </select> </td>
    </tr>
		<%} %>	
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Misc Deduction </td>
			<%
				strTemp = WI.fillTextValue("search_ded_index");
			%>
      <td height="24"  colspan="2"><select name="search_ded_index" id="select2">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction order by pre_deduct_name",strTemp,false)%>
      </select></td>
    </tr>
	<%
		strTemp = WI.fillTextValue("staff_type");
		String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="29"  colspan="2"> <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Department</td>
      <td height="29"  colspan="2">
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null) order by d_name", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex + " order by d_name", WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
				</label>			</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID</td>
      <td width="33%" height="29"><strong> 
        <input name="emp_id" type="text" size="12" maxlength="12" class="textbox" value="<%=WI.fillTextValue("emp_id")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong> <font size="1"> (for specific employee) </font></td>
      <td width="47%"><strong><a href="javascript:OpenSearch()"><img src="../../../images/search.gif" border="0"></a></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Show</td>
      <td height="29"  colspan="2"><select name="is_posted" id="select" onChange="ReloadPage()">
          <option value="0">Posted Deductions Only</option>
          <%if (WI.fillTextValue("is_posted").compareTo("1") == 0) {%>
          <option value="1" selected>Posted Deductions Deducted from Salary</option>
          <%}else{%>
          <option value="1">Posted Deductions Deducted from Salary</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("account_stat");
				if(request.getParameter("account_stat") == null)
					strTemp = "1";
			%>
      <td height="29"  colspan="2">
			<select name="account_stat" onChange="ReloadPage()">
        <option value="">ALL</option>
				<%
				for(int i = 0; i < astrUserStat.length; i++){
					if(strTemp.equals(Integer.toString(i))){
				%>
        <option value="<%=i%>" selected><%=astrUserStat[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrUserStat[i]%></option>
        <%}				
				}%>				
      </select></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("view_all");
				if(strTemp.length() > 0){
					strTemp = "checked";
				}else{
					strTemp = "";
				}
			%>
      <td height="29"  colspan="2"><input type="checkbox" name="view_all" value="1" <%=strTemp%> onClick="javascript:ProceedClicked();">
      view All </td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=prMiscDed.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=prMiscDed.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=prMiscDed.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
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
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
				<!--
				<input type="image" onClick="SearchEmployee()" src="../../../images/form_proceed.gif"> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
			onClick="javascript:ProceedClicked();">
				<font size="1">click to display employee list to print</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>	
	<%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <%if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/prMiscDed.defSearchSize;		
		if(iSearchResult % prMiscDed.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>  
    <tr>		
      <td align="right">Jump To page:
        <select name="jumpto" onChange="ProceedClicked();">
      <%
			strTemp = WI.fillTextValue("jumpto");
			if(strTemp == null || strTemp.length() ==0) 
				strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(strTemp.equals(Integer.toString(i))){%>
                  <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%}else{%>
                  <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%
					}
			}
			%>
      </select>
			</td>
    </tr>
		<%}
		}%>
    <tr> 
      <td><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a> click to print</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder" id="search1">
    <tr bgcolor="#B9B292">
      <td height="26" colspan="9" align="center" class="thinborder"><strong><font color="#000000" size="2">LIST 
      OF POSTED MISC. DEDUCTIONS</font></strong></td>
    </tr>
    <tr> 
      <td width="8%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE ID</font></strong></td>
      <td width="14%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="14%" align="center" class="thinborder"><strong><font size="1">DEDUCTION NAME</font></strong></td>
      <td width="11%" height="26" align="center" class="thinborder"><font size="1"><strong>PERIOD</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>			
      <td align="center" class="thinborder"><font size="1"><strong>POSTED BY</strong></font></td>  
			<% if(WI.fillTextValue("is_posted").equals("1")){ %>    
			<td align="center" class="thinborder"><font size="1"><strong>PAYABLE BALANCE </strong></font></td>
			<%}%>
      <td align="center" class="thinborder"><font size="1"><strong>REFERENCE/ REMARKS </strong></font></td>
    </tr>
    <% 	for (int i= 0; i < vRetResult.size(); i+=24){	%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <%
	String strTemp2 = (String)vRetResult.elementAt(i+5);
	if (strTemp2 == null)
		strTemp2 = (String)vRetResult.elementAt(i+7);
	else
		strTemp2 += WI.getStrValue((String)vRetResult.elementAt(i+7)," :: ","","");
		
%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11) +" - "+(String)vRetResult.elementAt(i+12)%></td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+13)%>&nbsp;</td>
      <td width="13%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
      <td width="8%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+15)%></td>
			<% if(WI.fillTextValue("is_posted").equals("1")){ 
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+17),true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
//			dTemp = Double.parseDouble(strTemp);
//			if(dTemp == 0d)
//				strTemp = "--";
			%>			
			<td width="10%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%}%>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+18),"");
				if(strTemp.length() > 0)
					strTemp += "<br>";				
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;");
			%>
      <td width="14%" class="thinborder"><%=strTemp%></td>
    </tr>
    <%} //end for loop%>
  </table>
 
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr> 
      <td height="26">&nbsp;</td>
    </tr>
</table> 
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="footer">
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
</table>
  
<input type="hidden" name="print_page">
<input type="hidden" name="proceedclicked">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>