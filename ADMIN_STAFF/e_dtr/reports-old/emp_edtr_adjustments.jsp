<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
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
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
function CallPrint()
{
	document.dtr_op.print_page.value="1"
}

function DeleteRecord(strInfo){

	document.dtr_op.info_index.value=strInfo;
	document.dtr_op.page_action.value="1";
	document.dtr_op.submit();
	
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.TimeInTimeOut" %>
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./edtr_adjustments_print.jsp" />
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
								"Admin/staff-eDaily Time Record-Employees with Adjustments",
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
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

ReportEDTR RE = new ReportEDTR(request);
TimeInTimeOut tRec = new TimeInTimeOut();

 strTemp = WI.fillTextValue("info_index");

int iAction = Integer.parseInt(WI.getStrValue(strTemp,"0"));

if (iAction == 1){	
	if(!tRec.operateOnAdjustments(dbOP,request,iAction))
		strErrMsg = tRec.getErrMsg();
	else
		strErrMsg = "Adjustment record deleted successfully";
}
vRetResult = RE.searchEDTRAdjustments(dbOP);

if (vRetResult == null){
	strErrMsg = RE.getErrMsg();
}else{
	iSearchResult = RE.getSearchCount();
}


%>
<form action="./emp_edtr_adjustments.jsp" name="dtr_op" >
<table width="100%" border="0" cellspacing="0" cellpadding="5">
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><strong>Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;:: 
      &nbsp;From: 
      <input name="from_date" type="text"  id="from_date" size="12" readonly="true"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>"> 
      <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
      : 
      <input name="to_date" type="text"  id="to_date" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>"> 
      <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;</td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td width="2%" height="25">&nbsp;</td>
    <td width="21%" height="25">Enter Employee ID </td>
    <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
    </td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr bgcolor="#FFFFFF"> 
          <td width="15%" height="25">Position</td>
          <td width="85%" height="25"><strong> 
            <%strTemp2 = WI.fillTextValue("emp_type");%>
            <select name="emp_type">
              <option value="">ALL</option>
              <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%> 
            </select>
            </strong></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td height="25">College </td>
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
              <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td height="25"><%=strTemp2%></td>
          <td height="25"> <select name="d_index">
              <% if(strTemp.compareTo("") ==0){//only if from non college.%>
              <option value="">All</option>
              <%}else{%>
              <option value="">All</option>
              <%} strTemp3 = WI.fillTextValue("d_index");%>
              <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
        </tr>
      </table></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif"> 
    </td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td><p>&nbsp;</p>
        </td>
  </tr>
<% if (vRetResult!= null) { %>
  <tr> 
      <td> 
          <% if (WI.fillTextValue("viewRecords").compareTo("1")==0){ 
		
			iSearchResult = RE.getSearchCount();
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
 		 %>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="58%"><b>Total Requests: <%=iSearchResult%> - Showing(<%=RE.getDisplayRange()%>)</b></td>
            <td width="39%">Jump To page: 
              <select name="jumpto" onChange="goToNextSearchPage();">
                <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                <option value="<%=i%>" selected><%=i%> of <%=iPageCount%></option>
                <%}else{%>
                <option value="<%=i%>" ><%=i%> of <%=iPageCount%></option>
                <%
					}
			}
			%>
              </select></td>
            <td width="3%"><input name="image2" type="image" onClick="CallPrint()" src="../../../images/print.gif" align="right" width="58" height="26"></td>
          </tr>
        </table>
        <hr size="1">
      <br> 
      <table width="100%" border="1" cellpadding="3" cellspacing="0">
          <tr bgcolor="#006A6A"> 
		  	<% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
            <td  colspan="7"><div align="center"><font color="#FFFFFF"><strong>LIST 
                OF EMPLOYEE DTR ADJUSTMENTS (<%=strTemp%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td width="13%" height="30" bgcolor="#EBEBEB"><strong><font size="1">EMPLOYEE ID</font></strong></td>
            <td width="12%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>STATUS</strong></font></td>
            <td width="12%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>DATE</strong></font></td>
            <td width="14%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>FROM </strong></font></td>
            <td width="15%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>ADJUSTED DATE</strong></font></td>
            <td width="14%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>ADJUSTED TIME</strong></font></td>
            <td width="10%" height="30" bgcolor="#EBEBEB">&nbsp;</td>
          </tr>
<% 
	String strTempName = null;
	long lTemp = 0l;
	for (int i = 0; i < vRetResult.size();  i+=10){
	if ((strTempName !=null) && (strTempName == ((String)vRetResult.elementAt(i+1)))){
		strTempName = "&nbsp";
	}else{
		strTempName = (String)vRetResult.elementAt(i+1);
	}
%>
   <tr> 
    <td><font size="1"><strong><%=strTempName%></strong></font></td> 
<%
	
lTemp = ((Long)vRetResult.elementAt(i+3)).longValue();
if (lTemp == 0){ 
	strTempName = "Time In";
	strTemp =  ((Long)vRetResult.elementAt(i+2)).toString();
	strTemp2 = (String)vRetResult.elementAt(i+4);
	strTemp3 = ((Long)vRetResult.elementAt(i+6)).toString();
	strTemp4 = (String)vRetResult.elementAt(i+8);
}else{
	strTempName = "Time Out";
	strTemp2 = (String)vRetResult.elementAt(i+5);
	strTemp3 = (String)vRetResult.elementAt(i+7);
	strTemp4 = (String)vRetResult.elementAt(i+9);
}	
	if (strTemp3!=null)
	 	strTemp3 = WI.formatDateTime(Long.parseLong(strTemp3),2);
	 else
	 	strTemp3 = "&nbsp;";	

%>

			<td><font size="1"><strong><%=strTempName%></strong></font></td>
            <td><font size="1"><strong><%=WI.getStrValue(strTemp2,"&nbsp;")%></strong></font></td>            
            <td><font size="1"><strong><%=WI.getStrValue(Long.toString(lTemp),"&nbsp;")%></strong></font></td>
            <td><font size="1"><strong><%=WI.getStrValue(strTemp4,"&nbsp;")%></strong></font></td>
            <td><font size="1"><strong><%=WI.getStrValue(strTemp3,"&nbsp;")%></strong></font></td>
            <td width="10%"><a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
          </tr>	
<%
	strTempName =(String)vRetResult.elementAt(i+1);
} // end for loop
%>
	    </table>
		
        <hr size="1">
        <img src="../../../images/print.gif" width="58" height="26" align="right"> 
	<%}%>
	</td>
  </tr>
<%}else{%>
  	<tr> 
    	  <td><strong><%=RE.getErrMsg()%></strong> </td>
	  </tr>
<%}%>
</table>        
<input type="hidden" name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>"> 
<input type="hidden" name="page_action">
<input type="hidden" name="viewRecords" value="0"> 
<input type="hidden" name="info_index">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>