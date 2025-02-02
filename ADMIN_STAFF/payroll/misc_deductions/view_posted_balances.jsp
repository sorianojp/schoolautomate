<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./view_posted_balances_print.jsp"/>
	<%
		return;}
	 
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	String strErrMsg = null;
	String strTemp = null;
	
try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-View/Print Posted","view_posted_balances.jsp");

	}catch(Exception exp)	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View Posted misc deductions</title>
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
function OpenSearch(){
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function ProceedClicked(){
	document.form_.print_page.value="";
	document.form_.proceedclicked.value= "1";
	ReloadPage();
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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
<%
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"view_posted_balances.jsp");
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
int i = 0;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName = {"Employee ID","Firstname",strTemp,"Department"};
	String[] astrSortByVal  = {"id_number","user_table.fname","c_name","d_name"};
	String[] astrUserStat  = {"Show only for resigned employees", "Show only valid employees"};

if(WI.fillTextValue("proceedclicked").length() > 0){
	vRetResult = prMiscDed.getPostedDeductionsWithPayable(dbOP, request);
	if (vRetResult == null){
		strErrMsg = prMiscDed.getErrMsg();
	}else
		iSearchResult = prMiscDed.getSearchCount();
}
%>
<body  bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./view_posted_balances.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        MISCELLANEOUS DEDUCTIONS WITH PAYABLE BALANCE PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="23" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg,"&nbsp")%></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="searchTable">

    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="29">&nbsp;</td>
      <td width="19%" height="29">Deduction name </td>
			<%
				strTemp = WI.fillTextValue("deduct_index");
			%>			
      <td height="29"><select name="deduct_index">
        <option value="">Select Deduction Name</option>
        <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction order by pre_deduct_name",strTemp,false)%>
      </select></td>
    </tr>
		<% String strCollegeIndex = WI.fillTextValue("c_index"); %>	
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="29"> <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Department</td>
      <td height="29">
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null) order by d_name", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex + " order by d_name", WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
				</label></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Office/Dept filter</td>
      <td height="29"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
(enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID</td>
      <td width="79%" height="29"><strong> 
        <input name="emp_id" type="text" size="12" maxlength="12" class="textbox" value="<%=WI.fillTextValue("emp_id")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch()"><img src="../../../images/search.gif" border="0"></a></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Deduction Type </td>
			<%
				strTemp = WI.fillTextValue("deduction_type");
			%>
      <td>
			<select name="deduction_type">
				<option value="">ALL</option>
				<%if(strTemp.equals("0")){%>
				<option value="0" selected>Regular posts</option>
				<%}else{%>
				<option value="0">Regular posts</option>
				<%}%>
				<%if(strTemp.equals("2")){%>
				<option value="2" selected>Recurring Deductions</option>
				<%}else{%>
				<option value="2">Recurring Deductions</option>
				<%}%>				
			</select>			</td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Show Option </td>
			<%
				strTemp = request.getParameter("account_stat");
				if(strTemp == null)
					strTemp = "1";
				else			
					strTemp = WI.fillTextValue("account_stat");
			%>									
      <td><select name="account_stat" onChange="ReloadPage()">
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
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23" colspan="2">&nbsp;<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        
        View result in single page </td>
    </tr>
    <tr> 
      <td height="29" colspan="3"><table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="1%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td width="29%" height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=prMiscDed.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="29%" height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=prMiscDed.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="29%" height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=prMiscDed.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="12%" height="15">&nbsp;</td>
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
 				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
				onClick="javascript:ProceedClicked();">
        <font size="1">click to display employee list to print.</font>			</td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table></td>
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
      </select></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>		
    <tr> 
      <td><div align="right"><font size="2">Number of Employees / rows Per 
        Page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a> 
          click to print</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="search2">
    <tr bgcolor="#CCCC99">  
      <td height="26" colspan="6" align="center"class="thinborder"><strong><font color="#00000" size="2">LIST 
        OF EMPLOYEES WITH PAYABLE BALANCE </font></strong></td>
    </tr>
    <tr> 
      <td width="9%" align="center" class="thinborder"><strong><font size="1">EMP ID</font></strong></td>
      <td width="28%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="15%" height="26" align="center"  class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>
      <td width="12%" align="center"  class="thinborder"><font size="1"><strong>AMOUNT POSTED </strong></font></td>
      <td align="center"  class="thinborder"><font size="1"><strong>PAYABLE BALANCE </strong></font></td>
      <td align="center"  class="thinborder"><font size="1"><strong>DETAILS</strong></font></td>
    </tr>
    <%
 		for (i= 0; i < vRetResult.size(); i+=25){%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></td>
      <td  class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
      <td height="24" align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true)%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp == 0d)
				strTemp = "--";
			%>			
      <td width="13%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+18);
				if(strTemp.equals("2"))
					strTemp = "Recurring deduction";
				else
					strTemp = "";
				
				
				if(strTemp.length() > 0)
					strTemp += "<br>";
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+9),"REF #: ","","");
				if(strTemp.length() > 0)
					strTemp += "<br>";
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+11),"Note : ","","");
			%>
      <td width="23%" class="thinborder">&nbsp;<%=strTemp%></td>
    </tr>
    <%}%>
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