<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscEarnings" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
function PrintPg(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
}
 -->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./print_posted.jsp"/>
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC EARNINGS-View Print Posted","view_print_posted.jsp");

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
														"Payroll","MISC EARNINGS",request.getRemoteAddr(),
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
	PRMiscEarnings prd = new PRMiscEarnings(request);
	boolean bolShowReleased = false;
	int iSearchResult = 0;
	int i = 0;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName    = {strTemp, "Department","Firstname","Lastname", "Date Release"};
	String[] astrSortByVal     = {"c_name","d_name", "emp.fname", "emp.lname", "date_release"};
	String[] astrUserStat  = {"Show only for resigned employees", "Show only valid employees"};
	if(WI.fillTextValue("proceedclicked").length() > 0){
		vRetResult = prd.searchMiscEarnings(dbOP);
		if (vRetResult == null)
			strErrMsg = prd.getErrMsg();
		else
			iSearchResult = prd.getSearchCount(); 
	} 
%>
</head>
<body  bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./view_print_posted.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : MISC. EARNINGS : VIEW/PRINT POSTED EARNINGS PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="23" bgcolor="#FFFFFF"><strong><%=WI.getStrValue(strErrMsg,"&nbsp")%></strong></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="searchTable">
   <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%">DATE</td>
      <td><strong> 
        <% strTemp= WI.fillTextValue("date_from");%>
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </strong> to&nbsp; <strong> 
        <%strTemp= WI.fillTextValue("date_to");%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		</strong><a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee Type</td>
      <td height="29">
	  	<%
			strTemp = WI.fillTextValue("employee_category");
		%>
	  	<select name="employee_category" onChange="ReloadPage()">
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
    <%} 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="10" colspan="2"> <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Department/Office</td>
      <td height="26" colspan="2"> <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID</td>
      <td width="75%" height="29"><strong> 
        <input name="emp_id" type="text" size="12" maxlength="12" class="textbox" value="<%=WI.fillTextValue("emp_id")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong> <font size="1"> (for specific employee) <strong><a href="javascript:OpenSearch()"></a></strong></font></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Show</td>
      <td height="29">
			<select name="is_posted" onChange="ReloadPage()">
					<option value="">ALL</option>	          
          <%if (WI.fillTextValue("is_posted").equals("0")) {%>
          <option value="0" selected>Posted Earnings(Not Released)</option>
          <%}else{%>
          <option value="0">Posted Earnings(Not Released)</option>
          <%}%>
					
          <%if (WI.fillTextValue("is_posted").equals("1")) {%>
          <option value="1" selected>Posted Earnings Released to Employee</option>
          <%}else{%>
          <option value="1">Posted Earnings Released to Employee</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("account_stat");
			%>			
      <td height="29"><select name="account_stat" onChange="ReloadPage()">
        <option value="">ALL</option>
        <%
				for(i = 0; i < astrUserStat.length; i++){
					if(strTemp.equals(Integer.toString(i))){
				%>
        <option value="<%=i%>" selected><%=astrUserStat[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrUserStat[i]%></option>
        <%}				
				}%>
      </select></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=prd.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=prd.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=prd.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
				<input name="image" type="image" onClick="ReloadPage()" src="../../../images/form_proceed.gif"> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:ProceedClicked();">
				<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
  </table>	
	<%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td align="right">
        <font size="2"> Number of Employees Per Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =20; i <=45 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
          <font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a> 
          click to print</font></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/prd.defSearchSize;		
	if(iSearchResult % prd.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td align="right"><font size="2">Jump To page:
          <select name="jumpto" onChange="ProceedClicked();">
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
      </font></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder" id="search1">
    <tr> 
			<%
				if(WI.fillTextValue("is_posted").equals("0"))
					strTemp = "LIST OF POSTED MISC. EARNINGS";
				else
					strTemp = "LIST OF RELEASED MISC. EARNINGS";
			%>
      <td height="26" colspan="7" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td width="9%" height="26" align="center" class="thinborder"><strong>EMPLOYEE ID</strong></td>
      <td width="26%" align="center" class="thinborder"><strong>EMPLOYEE NAME</strong></td>
      <td width="21%" align="center" class="thinborder"><strong>DEPARTMENT / OFFICE</strong></td>
      <td width="17%" align="center" class="thinborder"><strong>EARNING NAME</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
      <td align="center" class="thinborder"><strong>DATE POSTED</strong></td>
			<%if(WI.fillTextValue("is_posted").equals("0"))
					strTemp = "POSTED BY";
				else
					strTemp = "BALANCE";
			%>
      <td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
    </tr>
    <% String strTemp2 = null;
		for(i = 0; i<vRetResult.size(); i+=18){
	  %>		
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <%
	strTemp2 = (String)vRetResult.elementAt(i+5);
	if (strTemp2 == null)
		strTemp2 = (String)vRetResult.elementAt(i+7);
	else
		strTemp2 += WI.getStrValue((String)vRetResult.elementAt(i+7)," :: ","","");
		
%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+13);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td width="9%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
			<%if(WI.fillTextValue("is_posted").equals("0")){
					strTemp = (String)vRetResult.elementAt(i+15);
					strTemp2 = "left";
				}else{
					strTemp = (String)vRetResult.elementAt(i+17);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					strTemp2 = "right";
				}
			%>
      <td width="9%" align="<%=strTemp2%>" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
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