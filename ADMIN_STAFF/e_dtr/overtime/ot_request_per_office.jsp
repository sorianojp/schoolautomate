<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View OverTime Requests</title>
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
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function DeleteRequest(strIndex){
		var iCtr = document.dtr_op.max_entries.value;
		var bol1Selected  = false;
		
		for (var i = 0; i < iCtr ; i++){
			if(eval("document.dtr_op.checkbox"+i+".checked")){
				bol1Selected = true;
				break;
			}
		}
		
		if (!bol1Selected){
			alert ("Select at least 1 entry to be deleted");
			return;	
		}

		var varConfirm = confirm(" Confirm Delete Selected Records?");
		if (!varConfirm){
			return;
		}
		
		document.dtr_op.del_.src ="../../../images/blank.gif";
		document.dtr_op.submit();		
	}

	function ViewRecords(){
		document.dtr_op.print_page.value = "";
		document.dtr_op.viewAll.value=1;
	}

	function goToNextSearchPage()	{
		document.dtr_op.viewAll.value=1;
		document.dtr_op.submit();
	}
	function ViewDetails(index){
	
	var loadPg = "./validate_approve_ot.jsp?info_index="+index+"&iAction=3&my_home="+
		document.dtr_op.my_home.value;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
	
	}

	function printpage(){
		document.dtr_op.print_page.value = "1";
		document.dtr_op.submit();
	}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.requested_by.value;
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
	document.dtr_op.requested_by.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}	
	
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ //System.out.println("hellow1");%>
	<jsp:forward page="./ot_request_per_office_print.jsp" />
<%}
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");

	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	int i = 0;	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Overtime request (per Office)","ot_request_per_office.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","STATISTICS & REPORTS",
											request.getRemoteAddr(),"ot_request_per_office.jsp");	

if(bolMyHome && iAccessLevel == 0) { 
	iAccessLevel = 1;	
}

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
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName    = {"Date of OT", "Last Name(Requested for)"};

String[] astrSortByVal     = {"ot_specific_date", "sub_.lname"};

int iSearchResult = 0;

String strDateFrom = WI.fillTextValue("DateFrom");
String strDateTo = WI.fillTextValue("DateTo");


if (strDateFrom.length() ==0){
	String[] astrCutOffRange = eDTRUtil.getCurrentCutoffDateRange(dbOP,true);
	if (astrCutOffRange!= null && astrCutOffRange[0] != null){
		strDateFrom = astrCutOffRange[0];
		strDateTo = astrCutOffRange[1];
	}
}



ReportEDTR RE = new ReportEDTR(request);
eDTR.OverTime ot = new eDTR.OverTime();

String strPrevCName = null;
String strPrevDName = null;
String strCurCName = null;
String strCurDName = null;

Vector vRetResult = null;

if (WI.fillTextValue("viewAll").equals("1")){

	vRetResult = RE.searchOvertimePerOffice(dbOP);
	if (vRetResult==null){
		strErrMsg =  RE.getErrMsg();
	}else{
		iSearchResult = RE.getSearchCount();
	}
}
%>
<form action="./ot_request_per_office.jsp" method="post" name="dtr_op">
<input type="hidden" name="print_page">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        OVERTIME REQUESTS (PER OFFICE) PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="2">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
    <tr >
      <td width="16%" height="25"><strong>&nbsp;&nbsp;&nbsp;&nbsp;Date&nbsp;</strong></td>
      <td width="84%"><strong>&nbsp;From</strong>
        <input name="DateFrom" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateFrom','/')" value="<%=strDateFrom%>" size="10" maxlength="10">
        <a href="javascript:show_calendar('dtr_op.DateFrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;<strong>To</strong>
        <input name="DateTo" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateTo','/')" value="<%=strDateTo%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('dtr_op.DateTo');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="16%"><strong>&nbsp;Status </strong></td>
      <td width="84%"> <font size="1">
        <select name="status" id="status">
          <option value="">ALL</option>
          <% if (WI.fillTextValue("status").equals("1")){%>
          <option value="1" selected>APPROVED</option>
          <%}else{%>
          <option value="1">APPROVED</option>
          <%} if (WI.fillTextValue("status").equals("0")){%>
          <option value="0" selected>DISAPPROVED</option>
          <%}else{%>
          <option value="0" >DISAPPROVED</option>
          <%} if (WI.fillTextValue("status").equals("2")){%>
          <option value="2" selected>PENDING</option>
          <%}else{%>
          <option value="2">PENDING</option>
          <%}%>
        </select>
      </font></td>
    </tr>
    
    <tr>
      <td><strong>&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></strong></td>
      <td><select name="c_index">
                <option value="">N/A</option>
                <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <%if(bolHasTeam){%>
		<tr>
      		<td><strong>&nbsp;Team</strong></td>
      		<td><select name="team_index">
        		<option value="">All</option>
        			<%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
								" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      			</select></td>			
    	</tr>
	<%}%>
	<tr>
      		<td height="25" ><strong>show rendered overtime</strong></td>
			<%
				strTemp = "";
				if(WI.fillTextValue("by_dept").length() > 0)
					strTemp = " checked";
			%>			
      <td colspan="2"><input type="checkbox" name="by_dept" value="1" <%=strTemp%>></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td height="21" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    
    <tr>
      <td width="16%" height="21" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="84%" bgcolor="#FFFFFF">        <input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif" width="81" height="21">      </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="19" colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td  width="16%" bgcolor="#FFFFFF"><strong>Sort By </strong></td>
    <td width="29%" bgcolor="#FFFFFF"><select name="sort_by1">
      <option value="" selected>N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
    </select>
      <br>
      <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
					if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    <td width="55%" bgcolor="#FFFFFF"><select name="sort_by2">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
    </select>
      <br>
      <select name="sort_by2_con">
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
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
</table>
  <% if (vRetResult != null){ %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
 <% strTemp = WI.fillTextValue("show_division");
 	if (strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = ""; %>		
    <td colspan="4">&nbsp; </td>
	  <% strTemp = WI.fillTextValue("show_all");
			if (strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = ""; %>	
    <td colspan=2 align="right"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
check to show all result</td>
  </tr>
  <tr>
    <td colspan="4"><b>Total Requests: <%=iSearchResult%> 
	  <%if(strTemp.length() == 0){%>- Showing(<%=RE.getDisplayRange()%>) <%}%></b></td>
    <td width="26%">&nbsp;</td>
    <td width="31%" align="right">
	<% if (strTemp.length() == 0) {%> 
	
	Jump To page:
      <select name="jumpto" onChange="goToNextSearchPage();">
   <% 
	int iPageCount = iSearchResult/RE.defSearchSize;
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
	strTemp = request.getParameter("jumpto");
	
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
		for( i =1; i<= iPageCount; ++i ){
			if(i == Integer.parseInt(strTemp) ){%>
        <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%
				}
		}
	%>
      </select>	  
	<%}%>	  </td>
  </tr>
  <tr bgcolor="#F4FBF5">
    <td height="25" colspan="6" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME SCHEDULE REQUEST
    </strong></font></td>
  </tr>
  <tr>
    <td height="73" colspan="6"><table width="100%" height="80" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <td width="30%" align="center" class="thinborder"><font size="1"><strong>Requested For</strong></font></td>
		<td width="15%" align="center" class="thinborder"><font size="1"><strong>OT Code</strong></font></td>
        <td width="16%" align="center" class="thinborder"><font size="1"><strong>OT Date</strong></font></td>
        <td width="20%" align="center" class="thinborder"><font size="1"><strong>Inclusive Time</strong></font></td>
        <td width="8%" align="center" class="thinborder"><font size="1"><strong>No. of Hours</strong></font></td>        
 				<td width="8%" align="center" class="thinborder"><font size="1"><strong>Cost</strong></font></td>
				<td width="11%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
      </tr>
        <%
			int iCtr = 0;
 			for (i=0 ; i < vRetResult.size(); i+=35){ 
				strCurCName = WI.getStrValue((String)vRetResult.elementAt(i+21));
				strCurDName = WI.getStrValue((String)vRetResult.elementAt(i+23));
				
				if(strPrevCName == null || !strPrevCName.equals(strCurCName) ||
					 strPrevDName == null || !strPrevDName.equals(strCurDName)){
			 %>
        <tr>
					<%if(strCurCName.length() == 0  || strCurDName.length() == 0){
							strTemp = " ";			
						}else{
							strTemp = " - ";
						}
					%>
          <td height="20" colspan="7" class="thinborder"><strong>&nbsp;<%=WI.getStrValue(strCurCName,"")%><%=strTemp%><%=WI.getStrValue(strCurDName,"")%></strong></td>
          </tr>
        <tr>
				<%}%>
				<%
				strTemp = WI.formatName((String)vRetResult.elementAt(i+18), 
									(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
				strTemp += "(" + (String)vRetResult.elementAt(i+1) + ")";
				%>
        <td height="21" class="thinborder">&nbsp;<%=strTemp%></td>
		
		<td height="21" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+34))%></td>
		
        <% 
		   		strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+4);
			    }else{
					strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
							" - " +	(String)vRetResult.elementAt(i+5) + ")";
				}
			%>
        <td align="center" class="thinborder">          <%=strTemp%></td>
        <td align="center" nowrap class="thinborder">
					<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                               (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - 
                  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
        <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
        <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+28)%></td>
				<%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp.equals("1")){ 
					strTemp = "<strong><font color='#0000FF'> APPROVED </font></strong>";
				}else if (strTemp.equals("0")){
					strTemp = "<strong><font color='#FF0000'> DISAPPROVED </font></strong>";
				}else
					strTemp = "<strong> PENDING </strong>";
			%>
        <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
				
      </tr>
      <%
				strPrevCName = WI.getStrValue(strCurCName);
				strPrevDName = WI.getStrValue(strCurDName);
			}%>
    </table></td>
  </tr>

  <tr>
    <td colspan="6" align="right" height="18">&nbsp; </td>
  </tr>
  <tr>
    <td colspan="6" align="center"><a href="javascript:printpage();"><img src="../../../images/print.gif" 
			width="58" 	height="26"   border="0"></a> <font style="size:9px"> click to print result</font></td>
  </tr>
</table>

<% }%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td width="100%" height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="viewAll" value="">
<input type="hidden" name="ot_per_office" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>