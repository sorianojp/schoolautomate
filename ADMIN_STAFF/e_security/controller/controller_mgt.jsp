<%@ page language="java" import="utility.WebInterface,utility.CommonUtil, java.util.Vector, utility.DBOperation, eSC.Controller " %>

<%	
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP = null;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Trunstile Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript">
	
	function CancelOperation(){
		location = "./controller_mgt.jsp";
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this controller'))
				return;
		}		
		
		document.form_.page_action.value = strAction;
		

		if(strAction == '1') {
			document.form_.prepareToEdit.value='';
		
		}

		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;


		//alert("Page Action: " +strAction);
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
		
</script>

<body bgcolor="#8D5E47">
<form name="form_" action="controller_mgt.jsp" method="post">
<%	
	String strErrMsg = null;
	String strTemp = null;
	
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;
	
	Controller controller = new Controller();

	
	strTemp = WI.fillTextValue("page_action");
	//System.out.println("page action in jsp " +strTemp);	


	if(strTemp.length() > 0){							
	
		if(controller.operateOnController(request, dbOP, Integer.parseInt(strTemp)) == null)
			strErrMsg = controller.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Controller deleted successfully.";
			if(strTemp.equals("1"))
				strErrMsg = "Controller added successfully.";
			if(strTemp.equals("2"))
				strErrMsg = "Controller edited successfully.";
				
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = controller.operateOnController(request,dbOP, 4);	
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = controller.operateOnController(request,dbOP,3);
		//System.out.println("\n--- JSPvEditInfo: " + vEditInfo);
		if(vEditInfo == null)
			strErrMsg = controller.getErrMsg();
	}		
%>


	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#602000">
			<td height="25" colspan="5" align="center"><font color="#FFFFFF">
				<strong>::::  CONTROLLER MANAGEMENT  ::::</strong></font></td>
		</tr>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
			<tr>
			<td height="25">&nbsp;</td>
			<td align="right">Controller Name:</td>
		  <td>
			<%				
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(10);
				else
					strTemp = WI.fillTextValue("controller_name");
			%>

				<input name="controller_name" type="text" 
					class="textbox" value="<%=strTemp%>"
					maxlength="16" size="16" 
					onFocus="style.backgroundColor='#D3EBFF'" 
					onblur='style.backgroundColor="white"'>		
			</td>
		</tr>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td align="right">Serial Number:</td>
		  <td>
			<%				
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);
				else
					strTemp = WI.fillTextValue("controller_sn");
			%>

				<input name="controller_sn" type="text" 
					class="textbox" value="<%=strTemp%>"
					maxlength="16" size="16" 
					onFocus="style.backgroundColor='#D3EBFF'" 
					onblur='style.backgroundColor="white"'>		
			</td>
		</tr>

		<!------------------------------------ IP  address   --------------------------->
		<tr>
			<td height="25">&nbsp;</td>
			<td align="right" >IP Address: </td>

			<td>
			<%	if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = ((String)vEditInfo.elementAt(2));
				else
					strTemp = WI.fillTextValue("ip_addr");
			%>

			<input name="ip_addr" type="text" 
				class="textbox" value="<%=strTemp%>" size="20"
				maxlength="128" 
 				onFocus="style.backgroundColor='#D3EBFF'"
				onblur="style.backgroundColor='white'" />
			</td>
		</tr>	

		
		<!------------------------------------ Subnet mask   --------------------------->
		<tr>
			<td height="25">&nbsp;</td>
			<td align="right" >Subnet Mask: </td>
			<td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){

					strTemp = ((String)vEditInfo.elementAt(4));
					//System.out.println("\nJSP edit info result: " + strTemp);
				}		
				else
					strTemp = WI.fillTextValue("subnet_mask");
			%>
			
			<input name="subnet_mask" type="text" 
				class="textbox" value="<%=strTemp%>" size="20"
				maxlength="20" 
 				onFocus="style.backgroundColor='#D3EBFF'"
				onblur="style.backgroundColor='white'" />
			</td>
		</tr>	
					
			
			<!----------------------------------  Port Number   --------------------------->	
		<tr>
			<td height="25">&nbsp;</td>
			<td align="right" >Port Number: </td>		
			<td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){

					strTemp = (String)vEditInfo.elementAt(3);
					//System.out.println("\nJSP edit info result: " + strTemp);
				}		
				else
					strTemp = WI.fillTextValue("port_no");
				if(strTemp.length() == 0) 
					strTemp = "60000";
			%>

			<input name="port_no" type="text" 
				class="textbox" value="<%=strTemp%>" size="20"
				maxlength="20" 
 				onFocus="style.backgroundColor='#D3EBFF'"
				onblur="style.backgroundColor='white'" /> 
			(60000) 			
			</td>
		</tr>
		
		
				
			<!------------------------------------ Sleep time  --------------------------->	
		<tr>	
			<td height="25">&nbsp;</td>
			<td align="right" >Sleep Time:</td>
			<td>			
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){

					strTemp = (String)vEditInfo.elementAt(5);
					//System.out.println("\nJSP edit info result: " + strTemp);
				}		
				else
					strTemp = WI.fillTextValue("sleep_time");
				if(strTemp.length() == 0) 
					strTemp = "50";
			%>

			<input name="sleep_time" type="text" 
				class="textbox" value="<%=strTemp%>" size="20"
				maxlength="20" 
 				onFocus="style.backgroundColor='#D3EBFF'"
				onblur="style.backgroundColor='white'" />
			(in millisec, default to 50) 		
			</td>
		</tr>
		<tr><td>&nbsp;</td></tr>
		<!------------------------------------ Number of Doors   --------------------------->
		<tr>

			<td height="25">&nbsp;</td>
			<td align="right" >Number of Doors: </td>
			<td>

			<%
				if(vEditInfo != null && vEditInfo.size() > 0){

					strTemp = (String)vEditInfo.elementAt(6);
					//System.out.println("\nJSP edit info result: " + strTemp);
				}		
				else
					strTemp = WI.fillTextValue("no_of_doors");
			%>

			<select name="no_of_doors">	
				<option value="1">1</option>
				<option value="2">2</option>				
				<option value="4">4</option>
			</select>
			</td>
		</tr>
		
		<!------------------------------------IN and OUT status  --------------------------->		
		<tr>
			<td height="25">&nbsp;</td>			
			<td align="right"> IN and OUT Status</td>
			<td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0){

					strTemp = (String)vEditInfo.elementAt(7);
					//System.out.println("\nJSP edit info result: " + strTemp);
				}		
				else
					strTemp = WI.fillTextValue("in_out_stat");
			%>

			<select name="in_out_stat">	
				<option value="0">Allow IN and OUT</option>
				<option value="1">Allow IN only</option>
				<option value="2">Allow OUT only</option>				
			</select>			
			</td>
		</tr>		
		<tr>

			<td height="25">&nbsp;</td>
			<td align="right" >Doors for IN : </td>
		  <td>

			<%
				if(vEditInfo != null && vEditInfo.size() > 0){

					strTemp = (String)vEditInfo.elementAt(8);
					//System.out.println("\nJSP edit info result: " + strTemp);
				}		
				else
					strTemp = WI.fillTextValue("doors_for_in");
			%>
			<input name="doors_for_in" type="text" 
				class="textbox" value="<%=strTemp%>" size="20"
				maxlength="20" 
 				onFocus="style.backgroundColor='#D3EBFF'"
				onblur="style.backgroundColor='white'" />
				
			<i> numbers should be separated by a comma. Ex. 1,2,3</i>				
			
			</td>
		</tr>
		
		<tr>

			<td height="25">&nbsp;</td>
			<td align="right" >Doors for OUT: </td>
			<td>

			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(9);
				else
					strTemp = WI.fillTextValue("doors_for_out");
			%>

			<input name="doors_for_out" type="text" 
				class="textbox" value="<%=strTemp%>" size="20"
				maxlength="20" 
 				onFocus="style.backgroundColor='#D3EBFF'"
				onblur="style.backgroundColor='white'" />
			<i> numbers should be separated by a comma. Ex. 1,2,3</i>	
			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			
			<td>			
				<%if(strPrepareToEdit.equals("0")) {%>	
					<input type="button" name="saveBtn" value="ADD" onClick="PageAction('1','');" />					
				<%}else{					
					if(vEditInfo!=null && vEditInfo.size() > 0){%>
	
					<input type="button" name="edit" value="SAVE" 
						onclick="PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');" />						
			
					<%}%>
				<%}%>
				<input type="button" name="refreshBtn" value="REFRESH" onClick="CancelOperation();"/>	
			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bordercolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#602000" style="color:#FFFFFF;"> 
			<td height="25" colspan="12" align="center" class="thinborder">
				<strong>::: LIST OF CONTROLLERS ::: </strong>
			</td>
		</tr>
		<tr bgcolor="#FFFFF0">
			<td height="25" width="11%" align="center" class="thinborder"><strong>Count</strong></td>
			<td align="center" class="thinborder"><strong>Name</strong></td>
			<td align="center" class="thinborder"><strong>Serial Number</strong></td>
			<td align="center" class="thinborder"><strong>IP Address </strong></td>
			<td align="center" class="thinborder"><strong>Port Number </strong></td>
			<td align="center" class="thinborder"><strong>Subnet Mask </strong></td>
			<td align="center" class="thinborder"><strong>Sleep Time </strong></td>
			<td align="center" class="thinborder"><strong>Number of Doors </strong></td>
			<td align="center" class="thinborder"><strong>IN-OUT status</strong></td>
			<td align="center" class="thinborder"><strong>Doors for IN </strong></td>
			<td align="center" class="thinborder"><strong>Doors for OUT</strong></td>
			<td width="15%"align="center" class="thinborder"><strong>Options</strong></td>
		</tr>

	<%		
		int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 11, iCount++){%>
		<tr  align="center" bgcolor="#FFFFF0">
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">
				<%
				 	strTemp=(String)vRetResult.elementAt(i+7);
					if(strTemp.equals("0"))
						strTemp = "IN and OUT";
					else if(strTemp.equals("1"))
						strTemp = "IN only";
					else
						strTemp = "OUT only";				
				 %>
				 <%=strTemp%>	
			</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>		
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>		
			<td class="thinborder" >			
			<input type="button" name="editBtn" value="EDIT"
				onclick = "PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');" />
			
			<input type="button" name="deleteBtn" value="DELETE"
				onclick = "PageAction('0','<%=(String)vRetResult.elementAt(i)%>');" />												
			</td>
		</tr>
		<%}%>	
	<%}%>	
		<tr>
			<td height="25" bgcolor="#602000" colspan="12">&nbsp;</td>
		</tr>
	</table>	
	<input type="hidden" name="info_index">
	<input type="hidden" name="page_action">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
if(dbOP!=null)
	dbOP.cleanUP();
%>
