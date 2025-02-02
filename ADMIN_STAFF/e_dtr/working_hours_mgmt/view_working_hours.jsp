<%@ page language="java" import="utility.*,java.util.Vector, eDTR.ReportEDTR, 
                                             eDTR.eDTRUtil, eDTR.WorkingHour" %>

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
<title>Untitled Document</title>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function ReloadPage(){
		document.dtr_op.print_page.value="";
		document.dtr_op.submit();
	}
	
	function ViewRecords(){
		document.dtr_op.print_page.value="";
		document.dtr_op.submit();
	}
	function DeleteRecord(index){
		document.dtr_op.print_page.value="";
		document.dtr_op.info_index.value = index;
		document.dtr_op.page_action.value = 1;
	}	
	
	function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	}
	
	function PrintPage(){
		document.dtr_op.print_page.value="1";
		document.dtr_op.submit();
	}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
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
	document.dtr_op.emp_id.value = strID;
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
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	boolean bolProceed = true;

	if (WI.fillTextValue("print_page").equals("1")) {%> 
	<jsp:forward page="./view_working_hours_print.jsp" />
<%  return;}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT-View Working hours","view_working_hours.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"view_working_hours.jsp");	
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
if ((WI.fillTextValue("info_index").length()>0) && (WI.fillTextValue("page_action").equals("1"))){
	WorkingHour WH = new WorkingHour();

	if (!WH.deleteEmpWorkingHour(dbOP,request))
		strErrMsg = WH.getErrMsg();
}

ReportEDTR RE = new ReportEDTR(request);

int iSearchResult = 0;
String[] astrWeekDays = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}; 
String strWeekDay = null;
String[] astrDateOption = {"ALL", "Specific Dates only", "Started within specified range", "Ended within specified range", "Current Valid Only"}; 

vRetResult = RE.getEmployeeWorkingHours(dbOP,false);
if (vRetResult !=null){
	iSearchResult = RE.getSearchCount();
}else{
	strErrMsg = RE.getErrMsg();
}


%>
<form action="./view_working_hours.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT:::</strong></font></td> 
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#FFFFFF">
  		<strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong>      </td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("date_option");
			%>			
      <td height="25" bgcolor="#FFFFFF"><select name="date_option">
        <%for(int i = 0; i < astrDateOption.length; i++){
					if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrDateOption[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrDateOption[i]%></option>
        <%} 
				}%>
      </select></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td width="3%" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="17%" bgcolor="#FFFFFF">Date</td> 
      <td width="80%" height="25" bgcolor="#FFFFFF"><p>From: 
          <input name="date_from" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_from")%>"  size="10" maxlength="10" readonly="true">
          <a href="javascript:show_calendar('dtr_op.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
          : 
          <input name="date_to" type="text" class="textbox"  id="date_to" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="10" maxlength="10" readonly="true">
          <a href="javascript:show_calendar('dtr_op.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp;
      
      </td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#FFFFFF">
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" height="25"> Employee ID </td>
      <td width="19%" height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">      </td>
      <td width="61%"><font color="#FFFFFF" ><strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></strong></font>
			<label id="coa_info"></label></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF">
            <td width="18%" height="25">Employment Type</td>
            <td width="82%" height="25"><strong>
              <%strTemp2 = WI.fillTextValue("emp_type");%>
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%>
              </select>
            </strong></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
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
              </select>            </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><%=strTemp2%></td>
            <td height="25"><select name="d_index">
                <% if(strTemp.compareTo("") ==0){//only if from non college.%>
                <option value="">All</option>
                <%}else{%>
                <option value="">All</option>
                <%} strTemp3 = WI.fillTextValue("d_index");%>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%>
              </select>            </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25">Office/Dept filter</td>
            <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
          </tr>
      </table></td>
    </tr>
    
    <tr bgcolor="#FFFFFF">
      <td height="20">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_effective_date");
				if(strTemp.equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
			%>			
      <td height="20" colspan="3">&nbsp;<input type="checkbox" name="show_effective_date" value="1" <%=strTemp%>>
      show effective date range </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="40">&nbsp;</td>
      <td height="40" colspan="3"><input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif">      </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="40" colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
<%  if (vRetResult != null && vRetResult.size() > 0){	 %>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
		int iPageCount = 0;
		
		if (RE.defSearchSize > 0){ 
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
		}
%>
    <tr> 
      <td height="25">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
         <tr>
           <td>
		<% if (WI.fillTextValue("show_all").equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
		%>

	  		<input type="checkbox" name="show_all" value="1" <%=strTemp%>> 
				<font size="1">check to show all </font>
		</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr> 
        <td width="58%"><b>Total Requests: <%=iSearchResult%> 
<% if (!WI.fillTextValue("show_all").equals("1")) {%>
		- Showing(<%=RE.getDisplayRange()%>) <%}%></b></td>
        <td width="32%">
<%
if(iPageCount > 1 && !WI.fillTextValue("show_all").equals("1")){%>
				  Jump To page: 
                    <select name="jumpto" onChange="ReloadPage();">
                      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                    <option value="<%=i%>" selected><%=i%> of <%=iPageCount%></option>
                <%}else{%>
                    <option value="<%=i%>" ><%=i%> of <%=iPageCount%></option>
               <% }
			 }
			%>
                    </select>
<%}//show only if iPageCount > 0%>				  </td>
                  
            <td width="10%"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a></td>
          </tr>
      </table>      </td>
    </tr>
  </table>
 
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
	    <td height="25" colspan="4" align="center" bgcolor="#B9B292" class="thinborder">
		 			<strong>LIST OF WORKING HOURS</strong>
		</td>
    </tr>
    <tr align="center">
      <td width="35%" height="25" class="thinborder"><strong>NAME (EMPLOYEE ID)</strong></td>
      <td width="19%" height="25" class="thinborder"><strong>WEEK DAY</strong></td>
      <td width="38%" height="25" class="thinborder"><strong>WORKING HOURS</strong></td>
      <td width="8%" height="25" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% strTemp2 = null;

  		for(int i = 0 ; i< vRetResult.size(); i+=40){ %>
    <tr>
      <% if (strTemp2 == null){
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i + 1),
					(String)vRetResult.elementAt(i + 2), (String)vRetResult.elementAt(i + 3),4)+
					 " &nbsp;&nbsp; (" +(String)vRetResult.elementAt(i) + " )";

			   }else{
				if(strTemp2.equals((String)vRetResult.elementAt(i))){
					strTemp2 = "&nbsp;";
				}else{
					strTemp2 =WI.formatName((String)vRetResult.elementAt(i + 1),
											(String)vRetResult.elementAt(i + 2), 
											(String)vRetResult.elementAt(i + 3),4)+
					 " &nbsp;&nbsp; (" +(String)vRetResult.elementAt(i) + " )";
				}
  			  }
			%>
      <td class="thinborder"><strong><%=strTemp2%> </strong></td>
      <% 
				strTemp2 = (String)vRetResult.elementAt(i); // set curret ID.. 
				strTemp = (String)vRetResult.elementAt(i+4);
				if (strTemp== null)
					strTemp = (String)vRetResult.elementAt(i+19);
				
				if (strTemp != null)
					strTemp = astrWeekDays[Integer.parseInt(strTemp)];
				else {
					strTemp = (String)vRetResult.elementAt(i+33);
					if(strTemp == null){
						strTemp = "N/A Weekday";
					}else{
						strWeekDay = astrWeekDays[eDTRUtil.getWeekDay(strTemp) - 1];
						strTemp += WI.getStrValue(strWeekDay, " ","","");
 					}
				}
			%>
      <td class="thinborder"><%=strTemp%></td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+18); // flex hours.. 
				if (strTemp== null){
					strTemp =(String)vRetResult.elementAt(i+20);
					if(strTemp!=null){
						strTemp = eDTRUtil.formatTime((String)vRetResult.elementAt(i+20),
							(String)vRetResult.elementAt(i+21),(String)vRetResult.elementAt(i+22));
						strTemp += " - " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+23),
							(String)vRetResult.elementAt(i+24),(String)vRetResult.elementAt(i+25));
						if((String)vRetResult.elementAt(i+26)!=null){
							strTemp += " / " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+26),
								(String)vRetResult.elementAt(i+27),(String)vRetResult.elementAt(i+28));
							strTemp += " - " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+29),
								(String)vRetResult.elementAt(i+30),(String)vRetResult.elementAt(i+31));						
						}
					}else{
						strTemp = eDTRUtil.formatTime((String)vRetResult.elementAt(i+5),
							(String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7));
						strTemp += " - " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+8),
							(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10));
						if ((String)vRetResult.elementAt(i+11)!=null){
							strTemp += " / " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+11),
								(String)vRetResult.elementAt(i+12),(String)vRetResult.elementAt(i+13));
							strTemp += " - " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+14),
								(String)vRetResult.elementAt(i+15),(String)vRetResult.elementAt(i+16));
						}
					}
				}else{
					strTemp = eDTRUtil.formatTime((String)vRetResult.elementAt(i+5),
						(String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7));
					strTemp += " - " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+8),
						(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10));
					strTemp += " ("+ (String)vRetResult.elementAt(i+18) + " hours flex time)";
				}
				
				if(WI.fillTextValue("show_effective_date").length() > 0){
					strTemp3 = WI.getStrValue((String)vRetResult.elementAt(i+34));
					if(strTemp3.length() > 0)
						strTemp3 += WI.getStrValue((String)vRetResult.elementAt(i+35), " - ",""," - Present");

					strTemp3 = WI.getStrValue(strTemp3,"","<br>","");
					strTemp = strTemp3 + strTemp;
				}
			%>
      <td class="thinborder"><%=strTemp%></td>
      <td align="center" class="thinborder"><% if (iAccessLevel == 2){%>
          <input name="image" type="image" 
			  onClick='DeleteRecord("<%=(String)vRetResult.elementAt(i+32)%>")' src="../../../images/delete.gif" width="55"  height="28" border="0">
        <%}else{%>&nbsp;<%}%></td>
    </tr>
    <%}%>
  </table>
<%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="page_action" value="">
	<input type="hidden" name="print_page" value="">
	<input type="hidden" name="info_index" value="">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>