<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime" %>
<%
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
	function ReloadPage(){
		document.dtr_op.is_reloaded.value = "1";
		document.dtr_op.submit();
	}
	
	function CancelRecord(){
		location = "./validate_approve_ot.jsp?my_home="+document.dtr_op.my_home.value;
	}
	
	function DeleteRecord(index){
		document.dtr_op.info_index.value = index;
		document.dtr_op.iAction.value = 0;
	}	
	function UpdateRecord(index){
		if(document.dtr_op.ot_stat_reason.value.length < 3) {
			alert("Please enter remarks.");
			return;
		}	
	
		document.dtr_op.info_index.value = index;
		document.dtr_op.iAction.value = 2;
	}
	function ViewRecord(index){
		document.dtr_op.info_index.value = index;
		document.dtr_op.iAction.value =3;
	}
	function PrintPg() {
		var pgLoc = "./ot_print.jsp?DateFrom="+
		document.dtr_op.from_date.value+"&DateTo="+
		document.dtr_op.to_date.value +"&my_home="+ 
		document.dtr_op.my_home.value;
		
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.aEmp";
		var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
-->
</script>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Validate / Approved Overtime</title>
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
<body bgcolor="#D2AE72" class="bgDynamic" topmargin="0">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	int i = 3;
	boolean bolIsReloaded = WI.fillTextValue("is_reloaded").equals("1");
	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OverTime","validate_approve_ot.jsp");
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
														"eDaily Time Record","OVERTIME MANAGEMENT-APPROVE",request.getRemoteAddr(), 
														"validate_approve_ot.jsp");
														
// added for CLDHEI.. 
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome && iAccessLevel <= 0){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").equals("1"))
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//

	
													
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
OverTime OT = new OverTime();
Vector vRetResult = null;
Vector vIncTime = null;

vRetResult = null;
strTemp = WI.fillTextValue("info_index");
String page_action = WI.fillTextValue("iAction");
String strUserIndex = WI.fillTextValue("u_index");
String strcIndex = null;
String[] astrIncTime = {null, null, null, null, null, null};

if (page_action.equals("0")){

	vRetResult = OT.operateOnOTChangeStatus(dbOP,request,0);
	if (vRetResult == null)
		strErrMsg = OT.getErrMsg();
	else
		strErrMsg = " Overtime Request Deleted Successfully";

} else if (page_action.equals("2")){
	vRetResult = OT.operateOnOTChangeStatus(dbOP,request,2);
	if (vRetResult ==null)
		strErrMsg = OT.getErrMsg();
	else
		strErrMsg = "Overtime Request status Updated Successfully";
		
} 

	vRetResult = OT.getOTList(dbOP, request, WI.fillTextValue("info_index"), true);
 	if (vRetResult == null || vRetResult.size() <= 3)
		strErrMsg = OT.getErrMsg();
	else
		strUserIndex = (String)vRetResult.elementAt(20);
%>
<form action="./validate_approve_ot.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        VALIDATE/APPROVE OVERTIME::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><font size="3"><strong><%=strErrMsg%></strong></font>       
        <table width="100%" border="0" cellpadding="3" cellspacing="0">
          <tr>
            <td>&nbsp;</td>
            <td colspan="3">&nbsp;</td>
          </tr>
          <tr> 
            <td width="19%">Date of Request</td>
            <td colspan="3">
		<% if (vRetResult != null && vRetResult.size() > 3) { %>			
			<strong><%=(String)vRetResult.elementAt(i+2)%></strong>
		<%}else{%> 	&nbsp; <%}%>			</td>
          </tr>
          <tr> 
            <td>Requested by</td>
            <td width="24%">
		<% if (vRetResult != null && vRetResult.size() > 3) { %>			
			<strong> <%=(String)vRetResult.elementAt(i+15)%></strong>
		<%}else{%> 	&nbsp; <%}%>			</td>
            <td width="19%">Requested For</td>
            <td width="38%">&nbsp;
		<% if (vRetResult !=null && vRetResult.size()>3) { %>						
			<strong>
					<%=WI.getStrValue((String)vRetResult.elementAt(i+16))%></strong>
		<%}else{%> 	&nbsp; <%}%>			</td>
          </tr>
          <tr> 
            <td>Date/Days</td>
		  <% if (vRetResult !=null && vRetResult.size()>3) { 
		   		strTemp = (String)vRetResult.elementAt(i+7);
		   		if (strTemp  == null || strTemp.length() < 1)
		   			strTemp = (String)vRetResult.elementAt(i+5);
			}else{
				strTemp = "&nbsp;";
			}
		   %>
            <td><strong><%=strTemp%></strong></td>
      <%if (vRetResult !=null && vRetResult.size()>3) { 
					vIncTime = (Vector)vRetResult.elementAt(i+24);
					if(vIncTime != null && vIncTime.size() > 0){
						for(int o = 0; o < vIncTime.size(); o++)
							astrIncTime[o] = (String)vIncTime.elementAt(o);
					}
				}
			%> 
			      <td colspan="2">Inclusive Time :: <input name="am_hr_fr" type="text" size="1" maxlength="2" value="<%=WI.getStrValue(astrIncTime[0])%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
        : 
        <input name="am_min_fr" type="text" size="1" maxlength="2" value="<%=WI.getStrValue(astrIncTime[1])%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_from">
          <option value="0" >AM</option>
          <% if ((WI.getStrValue(astrIncTime[2])).equals("1")) {%>
          <option value="1" selected>PM</option>
          <% }else {%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input name="am_hr_to" type="text" size="1" maxlength="2" value="<%=WI.getStrValue(astrIncTime[3])%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input name="am_min_to" type="text" size="1" maxlength="2" value="<%=WI.getStrValue(astrIncTime[4])%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_to" >
          <option value="0" >AM</option>
          <% if ((WI.getStrValue(astrIncTime[5])).equals("1")){ %>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select>
        <input type="checkbox" value="1" name="is_nextday_logout">
        <font size="1">Next day logout </font></td>
          </tr>
					<%
						strTemp = null; 
						if (vRetResult !=null && vRetResult.size()>3) 
								strTemp = (String)vRetResult.elementAt(i+4);
					%> 
          <tr>
            <td>No. of Hours</td>		  						
            <td><input name="approved_hours" type="text" class="textbox" value="<%=strTemp%>"  						
						onBlur="style.backgroundColor='white'AllowOnlyFloat('form_','approved_hours');"
						onFocus="style.backgroundColor='#D3EBFF'" maxlength="4"  size="4" 
						onKeyUp="AllowOnlyFloat('form_','approved_hours');"> hrs </td>
            <td>Overtime Type </td>
						<% 
						if (vRetResult !=null && vRetResult.size()>3) { 
							strTemp = ((Long)vRetResult.elementAt(i+23)).toString();
						}else{
							strTemp = WI.fillTextValue("ot_type_index");
						}
						 %>
            <td>&nbsp;
              <select name="ot_type_index">
                 <%=dbOP.loadCombo("ot_type_index","ot_name", " from pr_ot_mgmt " +
		 					 " where is_valid = 1 and is_for_ot = 1 ", strTemp, false)%>
              </select>
            </td>
          </tr>
		  <% 
			 if (vRetResult !=null && vRetResult.size()>3) 
		   		strTemp = (String)vRetResult.elementAt(i+7);
			 else
				 	strTemp = null;	
	   	 
			 if (strTemp  != null && strTemp.length() > 1){%>
          <tr> 
            <td>Inclusive Dates</td>
            <td colspan="3"><strong><%=(String)vRetResult.elementAt(i+5)%> - <%=(String)vRetResult.elementAt(i+6)%></strong></td>
          </tr>
		  <%}%>
		  
          <tr> 
            <td align="right">Details of Overtime</td>
            <td colspan="3"> <table width="80%" border="1" cellpadding="2" cellspacing="0" bordercolor="#000000">
                <tr> 
	
			  <% if (vRetResult !=null && vRetResult.size()>3) 				  
				  	strTemp = (String)vRetResult.elementAt(6);
				else 
					strTemp = "&nbsp;";
				  
				if (strTemp == null || strTemp.length() < 1) strTemp ="No Details Given";
				%>
                  <td><strong><%=strTemp%></strong></td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td colspan="4"><table width="100%" height="53" border="0" cellpadding="3" cellspacing="0">
                <tr> 
                  <td width="20%">Remarks</td>
                  <% if (vRetResult != null && vRetResult.size() > 3 && !bolIsReloaded)
												strTemp = (String)vRetResult.elementAt(i+13);
										 else
										 		strTemp = WI.fillTextValue("ot_stat_reason");
									%> 
									<td colspan="3">
				  
				  	<input name="ot_stat_reason" type="text" size="64" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=WI.getStrValue(strTemp)%>">									 </td>
                </tr>
                <tr> 
                  <td>Approved by</td>
                  <td colspan="3">
		  <%   	if (vRetResult != null && vRetResult.size() > 3) {
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));
					if (strTemp == null || strTemp.length() == 0)  
						strTemp = (String)request.getSession(false).getAttribute("userId");
			    }
		  %> 
				  	<input name="aEmp" type="text" class="textbox" value="<%=strTemp%>"  
					<% if(WI.fillTextValue("my_home").equals("1")) {%> readonly  <%}%> 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	
					<% if(!WI.fillTextValue("my_home").equals("1")) {%>
						<a href="javascript:OpenSearch();">Search</a>
					<%}%>				 </td>
                </tr>
                <tr> 
                  <td>Date of Approval</td>
                  <td width="24%">
				  <% if (vRetResult != null && vRetResult.size() > 3) {%> 
				  <input name="DateApproval" type="text"  class="textbox" id="DateApproval" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12" readonly="true" 
				  					value="<%=WI.getStrValue((String)vRetResult.elementAt(i+12),"")%>">
                    <a href="javascript:show_calendar('dtr_op.DateApproval');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> <%}%>&nbsp;                  </td>
                  <td width="7%">Status</td>
                  <td width="49%">
				  <select name="status_new" >
				  <% if (vRetResult != null && vRetResult.size() > 3) 
						  	strTemp = (String)vRetResult.elementAt(i+10); 
						 else
						 	strTemp = "";
					  
                      if (strTemp.equals("PENDING")){%>
                      <option value="2" selected>Pending</option>
                      <%}else{ %>
                      <option value="2" >Pending</option>
                      <%}if (strTemp.equals("APPROVE")){%>
                      <option value="1" selected>Approved</option>
                      <%}else{ %>
                      <option value="1" >Approved</option>
                      <%}if (strTemp.equals("DISAPPROVE")){%>
                      <option value="0" selected>Disapproved</option>
                      <%}else{ %>
                      <option value="0" >Disapproved</option>
                      <%}%>
                  </select>									</td>
                </tr>
                <tr>
                  <td colspan="4"><strong>Charge to Office : </strong></td>
                </tr>
                <tr>
                  <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
									<%
									if (vRetResult != null && vRetResult.size() > 3 && !bolIsReloaded){
										strcIndex = (String)vRetResult.elementAt(21);
 										if(strTemp == null || strTemp.length() == 0)
											strcIndex = (String)vRetResult.elementAt(23);
 									}else
										strcIndex = WI.fillTextValue("c_index");
									
 									%>
                  <td colspan="3">
									<select name="c_index" onChange="ReloadPage();">
                    <option value="">N/A</option>
                    <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strcIndex, false)%>
                  </select>
									</td>
                </tr>
                <tr>
                  <td>Department/Office</td>
											<%
									if (vRetResult != null && vRetResult.size() > 3 && !bolIsReloaded){
										strTemp = (String)vRetResult.elementAt(22);
										if(strTemp == null || strTemp.length() == 0)
											strTemp = (String)vRetResult.elementAt(24);
									}else
										strTemp = WI.fillTextValue("d_index");
									
 									%>
                  <td colspan="3"><select name="d_index">
                    <option value="">All</option>
                    <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + 
										WI.getStrValue(strcIndex, " and c_index = ","","and (c_index is null or c_index = 0)") +
										" order by d_name asc",strTemp, false)%>
                  </select></td>
                </tr>
              </table></td>
          </tr>
          <tr>
            <td height="37" colspan="4" align="center">
              <% if (vRetResult != null && vRetResult.size() > 3 && iAccessLevel > 1) {%> 
              <input name="image2" type="image" onClick='UpdateRecord("<%=(String)vRetResult.elementAt(i+14)%>")' src="../../../images/save.gif" width="48" height="28">
              <font size="1">click to save changes</font> 
              <%}%>  <!--          <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
                to discard any changes</font>  --></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
<% //vRetResult = OT.getOTList(dbOP,request,null);
	if (false && vRetResult != null && vRetResult.size()>3) { %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <tr bgcolor="#A8A87B"> 
            <td height="25" colspan="9" align="center" class="thinborder"><font color="#FFFFFF">
            <strong>LIST OF OVERTIME SCHEDULE REQUEST 
            <% if (WI.getStrValue((String)vRetResult.elementAt(0)).length() > 0 && 
					WI.getStrValue((String)vRetResult.elementAt(1)).length() > 0) {%>
                (<%=(String)vRetResult.elementAt(0) %> - <%=(String)vRetResult.elementAt(1) %> ) 
            <%}%> 
                </strong></font>
            <input type="hidden" name="from_date" value="<%=(String)vRetResult.elementAt(0)%>">              <input type="hidden" name="to_date" value="<%=(String)vRetResult.elementAt(1)%>"></td></tr>
          <tr> 
            <td width="16%" class="thinborder"><strong><font size="1">&nbsp;Requested<br>
&nbsp;            by </font></strong></td>
            <td width="16%" class="thinborderBOTTOM"><font size="1"><strong>Requested<br> 
            For</strong></font></td>
            <td width="11%" class="thinborderBOTTOM"><font size="1"><strong>Date of <br>
            Request</strong></font></td>
            <td width="15%" class="thinborderBOTTOM"><font size="1"><strong>Date/Days</strong></font></td>
            <td width="13%" class="thinborderBOTTOM"><font size="1"><strong>Inclusive<br> 
            Time</strong></font></td>
            <td width="7%" class="thinborderBOTTOM"><font size="1"><strong>No. of<br> 
            Hours</strong></font></td>
            <td width="9%" class="thinborderBOTTOM"><font size="1"><strong>Status</strong></font></td>
            <td colspan="2" class="thinborderBOTTOM">&nbsp; </td>
          </tr>
		  
		<%	for (i=3 ; i < vRetResult.size(); i+=27){  %>
          <tr> 
            <td class="thinborder">&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i+16)%></font>
			</td>
            <td class="thinborderBOTTOM"><font size="1">&nbsp;
			<%=WI.getStrValue((String)vRetResult.elementAt(i+15))%></font></td>
            <td class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
            <% 
		   		strTemp = (String)vRetResult.elementAt(i+7);
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+5);
		   		}else{
					strTemp += "<br> (" +  (String)vRetResult.elementAt(i+5) + " - " +
									       (String)vRetResult.elementAt(i+6) + ")";
				}
		   %>
            <td class="thinborderBOTTOM"><font size="1"><%=strTemp%></font></td>
            <td class="thinborderBOTTOM"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+8)%> -<br>
              <%=(String)vRetResult.elementAt(i+9)%></font></td>
            <td class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+10);
				if(strTemp.equals("APPROVE")){ 
					strTemp = "<strong><font color=#0000FF>" + strTemp + "</font></strong>";
				}else if (strTemp.equals("DISAPPROVE")){
					strTemp = "<strong><font color=#FF0000>" + strTemp + "</font></strong>";
				}
			%>	

            <td class="thinborderBOTTOM"><font size="1"><%=strTemp%></font></td>
            <td width="5%" class="thinborderBOTTOM"> <font size="1">
              <input type="image" src="../../../images/view.gif" width="40" height="31" border="0" onClick='ViewRecord("<%=(String)vRetResult.elementAt(i+14)%>")'>
            </font></td>
            <td width="8%" class="thinborderBOTTOM"> 
			  <div align="center">
			    <% strTemp = (String)vRetResult.elementAt(i+10);
				if (iAccessLevel == 2 &&  !strTemp.equals("APPROVE") 
						&& !strTemp.equals("DISAPPROVE")) {%> 
                <input name="image" type="image" 
					onClick='DeleteRecord("<%=(String)vRetResult.elementAt(i+14)%>")' src="../../../images/delete.gif" width="55" height="28"> 
                <%}else{%> 
                N/A
                <%}%> 
            </div></td>
          </tr>
	  <%} %>
  </table>
		
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="18">&nbsp; </td>
    </tr>
<!-- disable print 
    <tr > 
      <td height="25" align="center">
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td>
    </tr>	
-->
  </table>
<%}else if (false){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	  	<tr ><td height="25" colspan="8" align="center"><strong>No Record of Overtime 
                Request </strong></td>
	  	</tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="18">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

	<input type="hidden" name="is_reloaded">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="iAction" value="3">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="u_index" value="<%=strUserIndex%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>